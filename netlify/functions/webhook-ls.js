/**
 * Lemon Squeezy Webhook Handler — v2 (SaaS Subscriptions)
 * ─────────────────────────────────────────────────────────
 * Handles:
 *   order_created           — one-shot PDF purchase (legacy)
 *   subscription_created    — new SaaS subscription (Bronze/Silver/Gold)
 *   subscription_updated    — renewal, payment retry
 *   subscription_cancelled  — user cancelled (access until period end)
 *   subscription_expired    — period ended, revoke access
 *   order_refunded          — refund, revoke access
 *
 * Env vars required:
 *   LS_WEBHOOK_SECRET    — from Lemon Squeezy → Settings → Webhooks
 *   SUPABASE_URL         — your Supabase project URL
 *   SUPABASE_SERVICE_KEY — service_role key (backend only, never on frontend)
 *   SITE_URL             — https://theprompt.studio
 */

const crypto = require('crypto');
const { createClient } = require('@supabase/supabase-js');

// ── Tier variant mapping ──────────────────────────────────────────────────────
// Replace these UUIDs with your real Lemon Squeezy variant IDs once created
// Checkout URL: /checkout?variant=VARIANT_ID&checkout[custom][tier]=bronze&checkout[custom][vertical]=immo
const TIER_VARIANT_MAP = {
  'BRONZE_VARIANT_UUID': 'bronze',
  'SILVER_VARIANT_UUID': 'silver',
  'GOLD_VARIANT_UUID':   'gold',
};

// ── Legacy PDF product mapping (one-shot orders) ──────────────────────────────
const LEGACY_VARIANT_MAP = {
  'dc72fcc3-ad4c-4f94-a689-4892d19434eb': { slug: 'immo',     pdf: 'ImmoPrompts_Pack_AgentImmo_Pro.pdf' },
  '4b484a81-7d4d-43ef-b827-9292eb78cd91': { slug: 'commerce', pdf: 'PromptCraft_Commerce_Pro.pdf' },
  'eaa20d56-b434-4335-80b4-942a637e77d1': { slug: 'legal',    pdf: 'PromptCraft_Legal_Pro.pdf' },
};

// ── Main handler ──────────────────────────────────────────────────────────────
exports.handler = async (event) => {
  if (event.httpMethod !== 'POST') {
    return { statusCode: 405, body: 'Method Not Allowed' };
  }

  // ── 1. Verify HMAC-SHA256 signature ────────────────────────────────────────
  const secret = process.env.LS_WEBHOOK_SECRET;
  if (!secret) {
    console.error('LS_WEBHOOK_SECRET not configured');
    return { statusCode: 500, body: 'Server misconfiguration' };
  }

  const signature = event.headers['x-signature'] || event.headers['X-Signature'];
  if (!signature) return { statusCode: 401, body: 'Missing signature' };

  const hash = crypto
    .createHmac('sha256', secret)
    .update(event.body)
    .digest('hex');

  if (!crypto.timingSafeEqual(Buffer.from(hash), Buffer.from(signature))) {
    console.warn('Invalid webhook signature');
    return { statusCode: 401, body: 'Invalid signature' };
  }

  // ── 2. Parse payload ────────────────────────────────────────────────────────
  let payload;
  try {
    payload = JSON.parse(event.body);
  } catch {
    return { statusCode: 400, body: 'Invalid JSON' };
  }

  const eventName = payload?.meta?.event_name;
  console.log('LS Webhook:', eventName, payload?.data?.id);

  const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);

  // ── 3. Route event ──────────────────────────────────────────────────────────
  try {
    switch (eventName) {
      case 'order_created':
        await handleOrderCreated(payload, supabase);
        break;
      case 'subscription_created':
        await handleSubscriptionCreated(payload, supabase);
        break;
      case 'subscription_updated':
        await handleSubscriptionUpdated(payload, supabase);
        break;
      case 'subscription_cancelled':
        await handleSubscriptionCancelled(payload, supabase);
        break;
      case 'subscription_expired':
        await handleSubscriptionExpired(payload, supabase);
        break;
      case 'order_refunded':
        await handleRefund(payload, supabase);
        break;
      default:
        console.log('Unhandled event, skipping:', eventName);
    }
  } catch (err) {
    console.error('Webhook error:', err);
    return { statusCode: 500, body: 'Processing error' };
  }

  return { statusCode: 200, body: 'OK' };
};

// ── Event handlers ────────────────────────────────────────────────────────────

/**
 * order_created — legacy one-shot PDF purchase
 */
async function handleOrderCreated(payload, supabase) {
  const attrs   = payload.data?.attributes || {};
  const email   = attrs.user_email;
  const name    = attrs.user_name || '';
  const orderId = String(payload.data?.id);
  const item    = attrs.first_order_item || {};

  if (!email) return console.error('No email in order payload');

  // Check if this is actually a subscription order (skip — handled by subscription_created)
  if (attrs.first_subscription_item) {
    console.log('Subscription order — waiting for subscription_created event');
    return;
  }

  // Resolve legacy PDF product
  const variantId   = String(item.variant_id || '');
  const legacyProd  = LEGACY_VARIANT_MAP[variantId];
  const customSlug  = payload.meta?.custom_data?.slug;
  const productSlug = legacyProd?.slug || customSlug || null;

  if (!productSlug) {
    console.warn('Could not resolve product for order', orderId);
    return;
  }

  console.log(`PDF order: ${email} → ${productSlug}`);
  const userId = await upsertUser(supabase, email, name);
  if (!userId) return;

  await supabase.from('user_products').upsert({
    user_id:        userId,
    product_slug:   productSlug,
    lemon_order_id: orderId,
    status:         'active',
  }, { onConflict: 'user_id,product_slug' });

  await sendMagicLink(supabase, email, productSlug, 'pdf');
}

/**
 * subscription_created — new SaaS subscription
 */
async function handleSubscriptionCreated(payload, supabase) {
  const attrs   = payload.data?.attributes || {};
  const email   = attrs.user_email;
  const name    = attrs.user_name || '';
  const subId   = String(payload.data?.id);
  const variantId = String(attrs.variant_id || '');

  if (!email) return console.error('No email in subscription payload');

  // Resolve tier from variant or custom data
  const customTier     = payload.meta?.custom_data?.tier?.toLowerCase();
  const customVertical = payload.meta?.custom_data?.vertical?.toLowerCase() || null;
  const tier = customTier || TIER_VARIANT_MAP[variantId] || 'bronze';

  // Period end
  const periodEnd = attrs.renews_at
    ? new Date(attrs.renews_at).toISOString()
    : (() => { const d = new Date(); d.setMonth(d.getMonth() + 1); return d.toISOString(); })();

  console.log(`Subscription created: ${email} → ${tier} (vertical: ${customVertical || 'all'})`);

  const userId = await upsertUser(supabase, email, name);
  if (!userId) return;

  // Upsert into subscriptions table (v3 schema — unique per user+vertical)
  const { error } = await supabase.from('subscriptions').upsert({
    user_id:                userId,
    tier,
    status:                 'active',
    vertical:               customVertical,
    lemon_subscription_id:  subId,
    lemon_order_id:         String(attrs.order_id || ''),
    current_period_start:   attrs.created_at || new Date().toISOString(),
    current_period_end:     periodEnd,
    updated_at:             new Date().toISOString(),
  }, { onConflict: 'user_id,vertical' });

  if (error) console.error('Subscription upsert error:', error);

  await sendMagicLink(supabase, email, tier, 'subscription');
}

/**
 * subscription_updated — renewal or plan change
 */
async function handleSubscriptionUpdated(payload, supabase) {
  const attrs = payload.data?.attributes || {};
  const subId = String(payload.data?.id);

  const periodEnd = attrs.renews_at
    ? new Date(attrs.renews_at).toISOString()
    : null;

  const update = {
    status:             attrs.status || 'active',
    updated_at:         new Date().toISOString(),
  };
  if (periodEnd) update.current_period_end = periodEnd;

  // Map LS status to our status
  const statusMap = {
    active:    'active',
    paused:    'active',      // still has access
    past_due:  'past_due',
    unpaid:    'past_due',
    cancelled: 'cancelled',
    expired:   'expired',
  };
  update.status = statusMap[attrs.status] || 'active';

  const { error } = await supabase
    .from('subscriptions')
    .update(update)
    .eq('lemon_subscription_id', subId);

  if (error) console.error('Subscription update error:', error);
  else console.log(`Subscription updated: ${subId} → status=${update.status}`);
}

/**
 * subscription_cancelled — user cancelled (keep access until period end)
 */
async function handleSubscriptionCancelled(payload, supabase) {
  const attrs = payload.data?.attributes || {};
  const subId = String(payload.data?.id);

  const periodEnd = attrs.ends_at
    ? new Date(attrs.ends_at).toISOString()
    : new Date().toISOString();

  const { error } = await supabase
    .from('subscriptions')
    .update({
      status:              'cancelled',
      cancelled_at:        new Date().toISOString(),
      current_period_end:  periodEnd,
      updated_at:          new Date().toISOString(),
    })
    .eq('lemon_subscription_id', subId);

  if (error) console.error('Subscription cancel error:', error);
  else console.log(`Subscription cancelled: ${subId}, access until ${periodEnd}`);
}

/**
 * subscription_expired — access period ended
 */
async function handleSubscriptionExpired(payload, supabase) {
  const subId = String(payload.data?.id);

  const { error } = await supabase
    .from('subscriptions')
    .update({
      status:     'expired',
      updated_at: new Date().toISOString(),
    })
    .eq('lemon_subscription_id', subId);

  if (error) console.error('Subscription expire error:', error);
  else console.log(`Subscription expired: ${subId}`);
}

/**
 * order_refunded — revoke PDF access
 */
async function handleRefund(payload, supabase) {
  const orderId = String(payload.data?.id);

  const { error } = await supabase
    .from('user_products')
    .update({ status: 'refunded' })
    .eq('lemon_order_id', orderId);

  if (error) console.error('Refund error:', error);
  else console.log(`Order refunded: ${orderId}`);
}

// ── Shared helpers ────────────────────────────────────────────────────────────

/**
 * Upsert user in Supabase Auth — returns user ID
 */
async function upsertUser(supabase, email, name) {
  // Look up existing users (paginated, but for our scale this is fine)
  const { data: list } = await supabase.auth.admin.listUsers({ perPage: 1000 });
  const existing = list?.users?.find(u => u.email === email);

  if (existing) {
    if (name && !existing.user_metadata?.full_name) {
      await supabase.auth.admin.updateUserById(existing.id, {
        user_metadata: { full_name: name },
      });
    }
    return existing.id;
  }

  const { data, error } = await supabase.auth.admin.createUser({
    email,
    email_confirm: true,
    user_metadata: { full_name: name },
  });

  if (error) {
    console.error('Create user error:', error);
    return null;
  }
  return data.user.id;
}

/**
 * Send magic link email so user can access their dashboard
 */
async function sendMagicLink(supabase, email, context, type) {
  const siteUrl = process.env.SITE_URL || 'https://theprompt.studio';
  const redirectTo = type === 'subscription'
    ? `${siteUrl}/dashboard?welcome=${context}`
    : `${siteUrl}/dashboard?welcome=pdf&slug=${context}`;

  const { error } = await supabase.auth.admin.generateLink({
    type: 'magiclink',
    email,
    options: { redirectTo },
  });

  if (error) console.error('Magic link error:', error);
  else console.log(`Magic link sent: ${email} → ${redirectTo}`);
}
