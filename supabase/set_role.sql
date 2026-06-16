-- ════════════════════════════════════════
-- MarketX — CHANGE A USER'S ROLE (dev helper)
-- ════════════════════════════════════════
-- Switch your account between roles to test each shell, then switch back.
-- Replace the email if needed. Run ONE of the statements below.

-- → ADMIN: access the admin dashboard (stores approval, users, finance, CMS, audit)
UPDATE profiles SET role = 'admin'
WHERE id = (SELECT id FROM auth.users WHERE email = 'see313see@gmail.com');

-- → VENDOR: access the vendor dashboard (orders, products, inventory, settings)
-- UPDATE profiles SET role = 'vendor'
-- WHERE id = (SELECT id FROM auth.users WHERE email = 'see313see@gmail.com');

-- → DELIVERY: access the delivery agent shell (active / history / profile)
-- UPDATE profiles SET role = 'delivery'
-- WHERE id = (SELECT id FROM auth.users WHERE email = 'see313see@gmail.com');

-- → CUSTOMER: back to the normal storefront
-- UPDATE profiles SET role = 'customer'
-- WHERE id = (SELECT id FROM auth.users WHERE email = 'see313see@gmail.com');

-- NOTE for VENDOR: the vendor shell shows the store you OWN. Claim the demo
-- Tech Store so its products/orders/settings appear (run with role = 'vendor'):
-- UPDATE stores SET owner_id = (SELECT id FROM auth.users WHERE email = 'see313see@gmail.com')
-- WHERE id = '33333333-3333-3333-3333-333333333301';

-- Verify current role:
SELECT u.email, p.role
FROM profiles p JOIN auth.users u ON u.id = p.id
WHERE u.email = 'see313see@gmail.com';
