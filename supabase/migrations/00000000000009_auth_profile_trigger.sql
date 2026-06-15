-- ════════════════════════════════════════
-- AUTO-CREATE PROFILE ON SIGN-UP
-- ════════════════════════════════════════
-- Supabase inserts new sign-ups into auth.users but does NOT create a
-- matching public.profiles row. Without this, the app's currentProfileProvider
-- returns nothing and role-based routing breaks right after login.
--
-- This trigger creates the profile automatically, copying full_name / phone
-- from the sign-up metadata when present. SECURITY DEFINER so it can insert
-- past RLS during the auth transaction.
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, phone)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'phone'
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Backfill: create profiles for any users who already signed up before this
-- trigger existed (e.g. accounts created while testing).
INSERT INTO public.profiles (id, full_name, phone)
SELECT u.id, u.raw_user_meta_data->>'full_name', u.raw_user_meta_data->>'phone'
FROM auth.users u
WHERE NOT EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = u.id);
