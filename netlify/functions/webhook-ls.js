/**
 * Lemon Squeezy Webhook Handler
 * ─────────────────────────────
 * Triggered on: order_created, subscription_created, subscription_cancelled
 *
 * Flow:
 *   1. Verify HMAC-SHA256 signature
 *   2. Parse event type + customer email
 *   3. Upsert user in Supabase Auth
 *   4. Grant product access in user_products table
 *   5. Send magic link email so user can access dashboard
 *
 * Env vars required:
 *   LS_WEBHOOK_SECRET    — from Lemon Squeezy → Settings → Webhooks
 *   SUPABASE_URL         — your Supabase project URL
 *   SUPABASE_SERVICE_KEY — service_role key (never expose on frontend)
 *   SITE_URL             — https://theprompt.studio
 */

const crypto = require('crypto');
const { createClient } = require('@supabase/supabase-js');

// ── Product variant UUID → slug mapping ──────────────────────────────────
// These UUIDs come from your Lemon Squeezy checkout URLs
const VARIANT_MAP = {
  'dc72fcc3-ad4c-4f94-a689-4892d19434eb': { slug: 'immo',     name: 'ImmoPrompts Pro',  pdf: 'ImmoPrompts_Pack_AgentImmo_Pro.pdf' },
  '4b484a81-7d4d-43ef-b827-9292eb78cd91': { slug: 'commerce', name: 'Commerce Pro',      pdf: 'PromptCraft_Commerce_Pro.pdf' },
  'eaa20d56-b434-4335-80b4-942a637e77d1': { slug: 'legal',    name: 'Juridique Pro',     pdf: 'PromptCraft_Legal_Pro.pdf' },
  '61739466-c94c-4f49-a6ee-c8b188204f3c': { slug: 'pro',      name: 'Pro Abonnement',    pdf: null },
};

// Also match by product name as fallback
const PRODUCT_NAME_MAP = {
  'immo':     { slug: 'immo',     pdf: 'ImmoPrompts_Pack_AgentImmo_Pro.pdf' },
  'commerce': { slug: 'commerce', pdf: 'PromptCraft_Commerce_Pro.pdf' },
  'legal':    { slug: 'legal',    pdf: 'PromptCraft_Legal_Pro.pdf' },
  'juridique':{ slug: 'legal',    pdf: 'PromptCraft_Legal_Pro.pdf' },
  'pro':      { slug: 'pro',      pdf: null },
};

exports.handler = async (event) => {
  // Only accept POST
  if (event.httpMethod !== 'POST') {
    return { statusCode: 405, body: 'Method Not Allowed' };
  }

  // ── 1. Verify Lemon Squeezy HMAC signature ────────────────────────────
  const secret = process.env.LS_WEBHOOK_SECRET;
  if (!secret) {
    console.error('LS_WEBHOOK_SECRET not set');
    return { statusCode: 500, body: 'Server misconfiguration' };
  }

  const signature = event.headers['x-signature'] || event.headers['X-Signature'];
  if (!signature) {
    return { statusCode: 401, body: 'Missing signature' };
  }

  const hash = crypto
    .createHmac('sha256', secret)
    .update(event.body)
    .digest('hex');

  if (!crypto.timingSafeEqual(Buffer.from(hash), Buffer.from(signature))) {
    console.warn('Invalid webhook signature');
    return { statusCode: 401, body: 'Invalid signature' };
  }

  // ── 2. Parse payload ──────────────────────────────────────────────────
  let payload;
  try {
    payload = JSON.parse(event.body);
  } catch (e) {
    return { statusCode: 400, body: 'Invalid JSON' };
  }

  const eventName = payload?.meta?.event_name;
  console.log('LS Webhook received:', eventName);

  // ── 3. Handle relevant events ─────────────────────────────────────────
  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_KEY
  );

  try {
    if (eventName === 'order_created') {
      await handleOrderCreated(payload, supabase);
    } else if (eventName === 'subscription_created') {
      await handleSubscriptionCreated(payload, supabase);
    } else if (eventName === 'subscription_cancelled' || eventName === 'subscription_expired') {
      await handleSubscriptionCancelled(payload, supabase);
    } else if (eventName === 'order_refunded') {
      await handleRefund(payload, supabase);
    }
    // Ignore other events (subscription_updated, etc.)
  } catch (err) {
    console.error('Webhook processing error:', err);
    return { statusCode: 500, body: 'Processing error' };
  }

  return { statusCode: 200, body: 'OK' };
};

// ─────────────────────────────────────────────────────────────────────────────
async function handleOrderCreated(payload, supabase) {
  const attrs = payload.data?.attributes || {};
  const email = attrs.user_email;
  const name  = attrs.user_name || '';
  const orderId = payload.data?.id;

  // Get product info from first_order_item
  const item = attrs.first_order_item || {};
  const productSlug = resolveProduct(
    payload.meta?.custom_data?.slug,
    item.variant_id,
    item.product_name,
    item.variant_name
  );

  if (!email) {
    console.error('No email in order payload');
    return;
  }
  if (!productSlug) {
    console.warn('Could not resolve product slug for order', orderId);
    return;
  }

  console.log(`Order created: ${email} → ${productSlug}`);

  // Upsert user
  const userId = await upsertUser(supabase, email, name);
  if (!userId) return;

  // Grant product access
  await grantAccess(supabase, userId, productSlug, {
    lemon_order_id: String(orderId),
    status: 'active',
  });

  // Send magic link to access dashboard
  await sendMagicLink(supabase, email, productSlug);
}

// ─────────────────────────────────────────────────────────────────────────────
async function handleSubscriptionCreated(payload, supabase) {
  const attrs = payload.data?.attributes || {};
  const email = attrs.user_email;
  const name  = attrs.user_name || '';
  const subId = payload.data?.id;
  const variantId = attrs.variant_id;

  const productSlug = resolveProduct(
    payload.meta?.custom_data?.slug,
    variantId,
    null,
    null
  ) || 'pro';

  if (!email) return;

  console.log(`Subscription created: ${email} → ${productSlug}`);

  const userId = await upsertUser(supabase, email, name);
  if (!userId) return;

  // Compute expiry (1 month for monthly sub, managed by webhook updates)
  const expiresAt = new Date();
  expiresAt.setMonth(expiresAt.getMonth() + 1);

  await grantAccess(supabase, userId, productSlug, {
    lemon_subscription_id: String(subId),
    status: 'active',
    expires_at: expiresAt.toISOString(),
  });

  await sendMagicLink(supabase, email, productSlug);
}

// ─────────────────────────────────────────────────────────────────────────────
async function handleSubscriptionCancelled(payload, supabase) {
  const attrs = payload.data?.attributes || {};
  const subId = String(payload.data?.id);

  const { error } = await supabase
    .from('user_products')
    .update({ status: 'cancelled', expires_at: new Date().toISOString() })
    .eq('lemon_subscription_id', subId);

  if (error) console.error('Cancel sub error:', error);
  else console.log(`Subscription cancelled: ${subId}`);
}

// ─────────────────────────────────────────────────────────────────────────────
async function handleRefund(payload, supabase) {
  const orderId = String(payload.data?.id);

  const { error } = await supabase
    .from('user_products')
    .update({ status: 'refunded' })
    .eq('lemon_order_id', orderId);

  if (error) console.error('Refund error:', error);
  else console.log(`Order refunded: ${orderId}`);
}

// ── Helpers ──────────────────────────────────────────────────────────────────

function resolveProduct(customSlug, variantId, productName, variantName) {
  // 1. Custom data (most reliable — passed via checkout URL ?checkout[custom][slug]=immo)
  if (customSlug && PRODUCT_NAME_MAP[customSlug.toLowerCase()]) {
    return PRODUCT_NAME_MAP[customSlug.toLowerCase()].slug;
  }

  // 2. Variant UUID (from our VARIANT_MAP)
  if (variantId) {
    const found = VARIANT_MAP[String(variantId)];
    if (found) return found.slug;
  }

  // 3. Product name pattern matching
  const combined = `${productName || ''} ${variantName || ''}`.toLowerCase();
  if (combined.includes('immo'))     return 'immo';
  if (combined.includes('commerce')) return 'commerce';
  if (combined.includes('legal') || combined.includes('juridique')) return 'legal';
  if (combined.includes('pro'))      return 'pro';

  return null;
}

async function upsertUser(supabase, email, name) {
  // Check if user exists
  const { data: existing } = await supabase.auth.admin.listUsers();
  const existingUser = existing?.users?.find(u => u.email === email);

  if (existingUser) {
    // Update name in metadata if needed
    if (name && !existingUser.user_metadata?.full_name) {
      await supabase.auth.admin.updateUserById(existingUser.id, {
        user_metadata: { full_name: name }
      });
    }
    return existingUser.id;
  }

  // Create new user
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

async function grantAccess(supabase, userId, productSlug, extra = {}) {
  // Upsert to avoid duplicate on retry
  const { error } = await supabase
    .from('user_products')
    .upsert(
      {
        user_id: userId,
        product_slug: productSlug,
        ...extra,
        updated_at: new Date().toISOString(),
      },
      { onConflict: 'user_id,product_slug', ignoreDuplicates: false }
    );

  if (error) console.error('Grant access error:', error);
  else console.log(`Access granted: ${userId} → ${productSlug}`);
}

async function sendMagicLink(supabase, email, productSlug) {
  const siteUrl = process.env.SITE_URL || 'https://theprompt.studio';
  const redirectTo = `${siteUrl}/dashboard?welcome=${productSlug}`;

  const { error } = await supabase.auth.admin.generateLink({
    type: 'magiclink',
    email,
    options: { redirectTo },
  });

  if (error) {
    console.error('Magic link error:', error);
  } else {
    console.log(`Magic link sent to ${email} → /dashboard?welcome=${productSlug}`);
  }
}
