-- ═══════════════════════════════════════════════════════════════════════════════
-- Grant full admin access to mathieu.thiao@gmail.com
-- Creates Gold subscriptions for ALL 10 verticals + sets admin flag
-- ═══════════════════════════════════════════════════════════════════════════════

-- 1. Set admin flag on profile
UPDATE public.profiles
SET is_admin = true, updated_at = now()
WHERE email = 'mathieu.thiao@gmail.com';

-- 2. Get user ID and insert Gold subscriptions for all 10 verticals
DO $$
DECLARE
  uid uuid;
  v text;
  verticals text[] := ARRAY['immo','commerce','legal','finance','marketing','rh','sante','education','restauration','freelance'];
BEGIN
  -- Find user ID
  SELECT id INTO uid FROM auth.users WHERE email = 'mathieu.thiao@gmail.com';

  IF uid IS NULL THEN
    RAISE EXCEPTION 'User mathieu.thiao@gmail.com not found in auth.users';
  END IF;

  -- Insert Gold subscription for each vertical
  FOREACH v IN ARRAY verticals
  LOOP
    INSERT INTO public.subscriptions (
      user_id, tier, status, vertical,
      current_period_start, current_period_end
    ) VALUES (
      uid, 'gold', 'active', v,
      now(), (now() + interval '10 years')
    )
    ON CONFLICT (user_id, vertical)
    DO UPDATE SET
      tier = 'gold',
      status = 'active',
      current_period_end = (now() + interval '10 years'),
      updated_at = now();
  END LOOP;

  RAISE NOTICE 'Admin access granted to % (user_id: %)', 'mathieu.thiao@gmail.com', uid;
END $$;

-- 3. Verify
SELECT p.email, p.is_admin, s.vertical, s.tier, s.status, s.current_period_end
FROM public.profiles p
JOIN public.subscriptions s ON s.user_id = p.id
WHERE p.email = 'mathieu.thiao@gmail.com'
ORDER BY s.vertical;
