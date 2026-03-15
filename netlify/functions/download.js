/**
 * GET /api/download?file=ImmoPrompts_Pack_AgentImmo_Pro.pdf
 * ──────────────────────────────────────────────────────────
 * Serves a protected PDF download after verifying:
 *   1. User is authenticated (valid JWT)
 *   2. User has purchased the product that corresponds to the file
 *
 * PDFs are stored in Supabase Storage (private bucket "downloads")
 * We generate a signed URL valid for 60 seconds.
 *
 * Env vars: SUPABASE_URL, SUPABASE_SERVICE_KEY
 */

const { createClient } = require('@supabase/supabase-js');

// Which file belongs to which product
const FILE_PRODUCT_MAP = {
  'ImmoPrompts_Pack_AgentImmo_Pro.pdf': ['immo', 'pro'],
  'PromptCraft_Commerce_Pro.pdf':       ['commerce', 'pro'],
  'PromptCraft_Legal_Pro.pdf':          ['legal', 'pro'],
};

exports.handler = async (event) => {
  const headers = {
    'Access-Control-Allow-Origin': process.env.SITE_URL || 'https://theprompt.studio',
    'Access-Control-Allow-Headers': 'Authorization',
    'Content-Type': 'application/json',
  };

  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 200, headers, body: '' };
  }
  if (event.httpMethod !== 'GET') {
    return { statusCode: 405, headers, body: JSON.stringify({ error: 'Method Not Allowed' }) };
  }

  // ── Get requested file ────────────────────────────────────────────────
  const filename = event.queryStringParameters?.file;
  if (!filename || !FILE_PRODUCT_MAP[filename]) {
    return { statusCode: 400, headers, body: JSON.stringify({ error: 'Invalid file' }) };
  }

  // ── Authenticate ──────────────────────────────────────────────────────
  const authHeader = event.headers.authorization || event.headers.Authorization;
  if (!authHeader?.startsWith('Bearer ')) {
    return { statusCode: 401, headers, body: JSON.stringify({ error: 'Authentication required' }) };
  }

  const token = authHeader.replace('Bearer ', '');
  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_KEY
  );

  const { data: { user }, error: authError } = await supabase.auth.getUser(token);
  if (authError || !user) {
    return { statusCode: 401, headers, body: JSON.stringify({ error: 'Invalid token' }) };
  }

  // ── Check product access ──────────────────────────────────────────────
  const allowedSlugs = FILE_PRODUCT_MAP[filename];

  const { data: access, error: dbError } = await supabase
    .from('user_products')
    .select('product_slug, expires_at')
    .eq('user_id', user.id)
    .eq('status', 'active')
    .in('product_slug', allowedSlugs);

  if (dbError) {
    console.error('DB error:', dbError);
    return { statusCode: 500, headers, body: JSON.stringify({ error: 'Database error' }) };
  }

  // Filter out expired subscriptions
  const now = new Date();
  const hasAccess = (access || []).some(p => !p.expires_at || new Date(p.expires_at) > now);

  if (!hasAccess) {
    return {
      statusCode: 403,
      headers,
      body: JSON.stringify({
        error: 'Access denied',
        message: 'You need to purchase this product to download it.',
      }),
    };
  }

  // ── Generate signed download URL from Supabase Storage ───────────────
  // Files are stored in a private bucket called "downloads"
  const { data: signedUrl, error: storageError } = await supabase.storage
    .from('downloads')
    .createSignedUrl(filename, 60); // 60 second expiry

  if (storageError || !signedUrl) {
    console.error('Storage error:', storageError);
    return { statusCode: 500, headers, body: JSON.stringify({ error: 'Could not generate download link' }) };
  }

  // Log the download
  await supabase
    .from('download_logs')
    .insert({ user_id: user.id, filename, downloaded_at: now.toISOString() })
    .then(() => {}); // Non-blocking

  return {
    statusCode: 200,
    headers,
    body: JSON.stringify({
      url: signedUrl.signedUrl,
      expires_in: 60,
      filename,
    }),
  };
};
