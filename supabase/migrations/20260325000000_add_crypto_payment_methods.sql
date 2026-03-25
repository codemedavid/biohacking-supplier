-- Add crypto payment methods: BTC (Native SegWit), BTC (SegWit), USDT (Ethereum)

INSERT INTO payment_methods (id, name, account_number, account_name, qr_code_url, active, sort_order)
VALUES
  ('btc-native-segwit', 'BTC (Native SegWit)', 'Scan QR code to get address', 'Bitcoin', '/payment-qr/btc-native-segwit.jpg', true, 1),
  ('btc-segwit', 'BTC (SegWit)', 'Scan QR code to get address', 'Bitcoin', '/payment-qr/btc-segwit.jpg', true, 2),
  ('usdt-ethereum', 'USDT (Ethereum)', 'Scan QR code to get address', 'Tether USD', '/payment-qr/usdt-ethereum.jpg', true, 3)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  qr_code_url = EXCLUDED.qr_code_url,
  active = EXCLUDED.active,
  sort_order = EXCLUDED.sort_order,
  updated_at = now();
