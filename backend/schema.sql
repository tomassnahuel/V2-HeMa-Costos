CREATE TABLE IF NOT EXISTS licenses (
  email TEXT PRIMARY KEY,
  status TEXT NOT NULL CHECK (status IN ('active', 'revoked')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS users (
  email TEXT PRIMARY KEY,
  device_id TEXT NOT NULL,
  last_seen TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS auth_codes (
  id BIGSERIAL PRIMARY KEY,
  email TEXT NOT NULL,
  code_hash TEXT NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  attempts INTEGER NOT NULL DEFAULT 0,
  blocked_until TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS auth_codes_email_created_at_idx
  ON auth_codes (email, created_at DESC);

CREATE INDEX IF NOT EXISTS auth_codes_email_expires_idx
  ON auth_codes (email, expires_at);

CREATE INDEX IF NOT EXISTS auth_codes_email_blocked_idx
  ON auth_codes (email, blocked_until);