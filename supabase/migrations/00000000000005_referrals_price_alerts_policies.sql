-- REFERRALS: a user can read referral rows where they are either the
-- referrer or the referred party, and can record a referral they initiated.
CREATE POLICY "referrals_own_read" ON referrals FOR SELECT USING (
  auth.uid() = referrer_id OR auth.uid() = referred_id
);

CREATE POLICY "referrals_referrer_insert" ON referrals FOR INSERT WITH CHECK (
  auth.uid() = referrer_id
);

-- PRICE ALERTS: users fully manage their own alerts.
CREATE POLICY "price_alerts_own" ON price_alerts FOR ALL USING (
  auth.uid() = user_id
);
