-- ============================================================================
-- ADMIN EMAIL NOTIFICATIONS
-- Sends an email to admin when a new bug report or tool suggestion is submitted
--
-- OPTION 1: Supabase Database Webhook (recommended — no code needed)
--   Go to Database → Webhooks → Create webhook:
--   - Table: bug_reports, Event: INSERT
--   - URL: your Edge Function or email service endpoint
--   Repeat for tool_suggestions
--
-- OPTION 2: Supabase Edge Function (below)
--   Deploy this as a Supabase Edge Function, then create a DB webhook trigger
-- ============================================================================

-- ── Option 2a: pg_net HTTP call on insert (if pg_net extension is enabled) ──
-- This calls a webhook URL whenever a new bug report or suggestion is created.
-- You can point this to a Zapier/Make webhook that sends an email.

-- Enable pg_net if not already
-- CREATE EXTENSION IF NOT EXISTS pg_net;

-- ── Trigger function for bug reports ──
CREATE OR REPLACE FUNCTION notify_admin_new_bug()
RETURNS TRIGGER AS $$
DECLARE
  payload JSONB;
BEGIN
  payload := jsonb_build_object(
    'type', 'new_bug_report',
    'id', NEW.id,
    'title', NEW.title,
    'severity', NEW.severity,
    'category', NEW.category,
    'vertical', NEW.vertical,
    'tool_slug', NEW.tool_slug,
    'description', LEFT(NEW.description, 200),
    'created_at', NEW.created_at,
    'admin_url', 'https://theprompt.studio/admin.html#bugs'
  );

  -- Option A: Use pg_net to call an external webhook (Zapier, Make, etc.)
  -- Uncomment and set your webhook URL:
  -- PERFORM net.http_post(
  --   'https://hooks.zapier.com/hooks/catch/YOUR_HOOK_ID',
  --   payload::text,
  --   '{"Content-Type": "application/json"}'
  -- );

  -- Option B: Insert into a notifications queue table (processed by Edge Function)
  INSERT INTO admin_notifications (type, payload) VALUES ('new_bug', payload)
  ON CONFLICT DO NOTHING;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ── Trigger function for tool suggestions ──
CREATE OR REPLACE FUNCTION notify_admin_new_suggestion()
RETURNS TRIGGER AS $$
DECLARE
  payload JSONB;
BEGIN
  payload := jsonb_build_object(
    'type', 'new_tool_suggestion',
    'id', NEW.id,
    'tool_name', NEW.tool_name,
    'priority', NEW.priority,
    'vertical', NEW.vertical,
    'description', LEFT(NEW.description, 200),
    'vote_count', NEW.vote_count,
    'created_at', NEW.created_at,
    'admin_url', 'https://theprompt.studio/admin.html#suggestions'
  );

  INSERT INTO admin_notifications (type, payload) VALUES ('new_suggestion', payload)
  ON CONFLICT DO NOTHING;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ── Notifications queue table ──
CREATE TABLE IF NOT EXISTS admin_notifications (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type        TEXT NOT NULL,
  payload     JSONB NOT NULL DEFAULT '{}',
  sent        BOOLEAN NOT NULL DEFAULT false,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_admin_notif_unsent ON admin_notifications (sent) WHERE sent = false;

-- ── Attach triggers ──
DROP TRIGGER IF EXISTS trg_notify_new_bug ON bug_reports;
CREATE TRIGGER trg_notify_new_bug
  AFTER INSERT ON bug_reports
  FOR EACH ROW
  EXECUTE FUNCTION notify_admin_new_bug();

DROP TRIGGER IF EXISTS trg_notify_new_suggestion ON tool_suggestions;
CREATE TRIGGER trg_notify_new_suggestion
  AFTER INSERT ON tool_suggestions
  FOR EACH ROW
  EXECUTE FUNCTION notify_admin_new_suggestion();

-- ============================================================================
-- EDGE FUNCTION: Process admin_notifications queue and send emails
-- Deploy as: supabase functions deploy notify-admin
-- Schedule with: pg_cron every 5 minutes, or call via Database Webhook
--
-- // supabase/functions/notify-admin/index.ts
-- import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
-- import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
--
-- serve(async () => {
--   const sb = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
--   const { data: notifs } = await sb.from("admin_notifications").select("*").eq("sent", false).limit(20);
--   if (!notifs?.length) return new Response("No pending notifications");
--
--   for (const n of notifs) {
--     // Send email via Resend, SendGrid, or any email API
--     await fetch("https://api.resend.com/emails", {
--       method: "POST",
--       headers: { Authorization: `Bearer ${Deno.env.get("RESEND_API_KEY")}`, "Content-Type": "application/json" },
--       body: JSON.stringify({
--         from: "The Prompt Studio <notifications@theprompt.studio>",
--         to: "mathieu.thiao@gmail.com",
--         subject: n.type === "new_bug"
--           ? `🐛 Nouveau bug: ${n.payload.title} (${n.payload.severity})`
--           : `💡 Nouvelle suggestion: ${n.payload.tool_name}`,
--         html: `<h2>${n.payload.title || n.payload.tool_name}</h2>
--                <p>${n.payload.description}</p>
--                <p><strong>Vertical:</strong> ${n.payload.vertical || "–"}</p>
--                <p><a href="${n.payload.admin_url}">Voir dans l'admin →</a></p>`,
--       }),
--     });
--     await sb.from("admin_notifications").update({ sent: true }).eq("id", n.id);
--   }
--   return new Response(`Processed ${notifs.length} notifications`);
-- });
-- ============================================================================
