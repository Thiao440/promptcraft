/**
 * GET /api/download
 * ─────────────────
 * Legacy endpoint — PDF pack downloads have been discontinued.
 * All access is now managed via subscriptions (Starter/Pro/Gold/Team).
 *
 * This function is kept as a stub to return a clean error if any
 * old link is still referenced somewhere.
 */

exports.handler = async (event) => {
  const headers = {
    'Access-Control-Allow-Origin': process.env.SITE_URL || 'https://theprompt.studio',
    'Access-Control-Allow-Headers': 'Authorization',
    'Content-Type': 'application/json',
  };

  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 200, headers, body: '' };
  }

  return {
    statusCode: 410,
    headers,
    body: JSON.stringify({
      error: 'Gone',
      message: 'Les téléchargements PDF ne sont plus disponibles. Accédez à vos outils via votre abonnement sur le dashboard.',
    }),
  };
};
