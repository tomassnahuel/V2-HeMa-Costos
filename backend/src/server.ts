
console.log("DATABASE_URL:", process.env.DATABASE_URL);

import 'dotenv/config';



import express, { Request, Response } from 'express';
import { Pool, PoolClient, QueryResult } from 'pg';
import crypto from 'node:crypto';

const app = express();
app.use(express.json());

const pool = new Pool({
  //connectionString: process.env.DATABASE_URL,
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT),
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_DATABASE,
  ssl: { rejectUnauthorized: false }
});

/*const pool = new Pool({
  user: 'postgres',
  password: '2350',
  host: 'localhost',
  port: 5432,
  database: 'licenses_db',
});*/

const CODE_TTL_MINUTES = 5;
const EMAIL_REQUEST_WINDOW_SECONDS = 60;
const EMAIL_REQUEST_HOURLY_LIMIT = 5;
const MAX_VERIFY_ATTEMPTS = 5;
const DEVICE_CONFLICT_WINDOW_MINUTES = 10;

const GENERIC_REQUEST_CODE_RESPONSE = {
  ok: true,
  message: 'If the email is eligible, a verification code will be sent.',
};

const SCHEMA_SQL = `
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
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS auth_codes_email_created_at_idx
  ON auth_codes (email, created_at DESC);
`;

type RequestCodeBody = {
  email?: string;
};

type VerifyCodeBody = {
  email?: string;
  code?: string;
  device_id?: string;
};

  //Tipos de resultados
  type LicenseErrorOutcome ={
    status: 403;
    body: { error: string };
  };
  type CodeOutcome = {
    shouldSend: boolean;
    code: string;
  };
  type TooManyRequestsOutcome = {
    status: 429;
    body: { error: string };
  };

  //Union type para el resultado de la transacción
  type Outcome = LicenseErrorOutcome | CodeOutcome | TooManyRequestsOutcome;


function normalizeEmail(email: string): string {
  return email.trim().toLowerCase();
}

function hashSHA256(value: string): string {
  return crypto.createHash('sha256').update(value, 'utf8').digest('hex');
}

function generateCode(): string {
  return crypto.randomInt(0, 1_000_000).toString().padStart(6, '0');
}

async function sendEmail(email: string, code: string): Promise<void> {
  console.info(`[sendEmail stub] Send code ${code} to ${email} via Resend.`);
}

async function withTransaction<T>(handler: (client: PoolClient) => Promise<T>): Promise<T> {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const result = await handler(client);
    await client.query('COMMIT');
    return result;
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

async function hasActiveLicense(client: PoolClient, email: string): Promise<boolean> {
  const query = `
    SELECT 1
    FROM licenses
    WHERE email = $1
      AND status = 'active'
    LIMIT 1
  `;
  const result = await client.query(query, [email]);
  return !!result.rowCount;
}

async function checkRequestRateLimit(client: PoolClient, email: string): Promise<boolean> {
  const query = `
    SELECT
      COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '1 hour')::INT AS hour_count,
      MAX(created_at) AS last_created_at
    FROM auth_codes
    WHERE email = $1
  `;
  const result = await client.query<{ hour_count: number; last_created_at: Date | null }>(query, [email]);
  const row = result.rows[0];
  if (!row) {
    return true;
  }

  if (row.hour_count >= EMAIL_REQUEST_HOURLY_LIMIT) {
    return false;
  }

  if (!row.last_created_at) {
    return true;
  }

  const secondsSinceLastRequest = (Date.now() - new Date(row.last_created_at).getTime()) / 1000;
  return secondsSinceLastRequest >= EMAIL_REQUEST_WINDOW_SECONDS;
}

async function storeAuthCode(client: PoolClient, email: string, codeHash: string): Promise<void> {
  
    await client.query(`DELETE FROM auth_codes WHERE email = $1`, [email]);

    const query = `
    INSERT INTO auth_codes (email, code_hash, expires_at, attempts)
    VALUES ($1, $2, NOW() + ($3 || ' minutes')::INTERVAL, 0)
  `;
  await client.query(query, [email, codeHash, CODE_TTL_MINUTES]);
}

async function getLatestAuthCodeForUpdate(client: PoolClient, email: string) {
  const query = `
    SELECT id, code_hash, expires_at, attempts, created_at, blocked_until
    FROM auth_codes
    WHERE email = $1
    ORDER BY created_at DESC
    LIMIT 1
    FOR UPDATE
  `;
  const result = await client.query<{
    id: number;
    code_hash: string;
    expires_at: Date;
    attempts: number;
    created_at: Date;
    blocked_until: Date | null;
  }>(query, [email]);
  return result.rows[0] ?? null;
}

async function incrementCodeAttempts(client: PoolClient, authCodeId: number): Promise<number> {
  const query = `
    UPDATE auth_codes
    SET attempts = attempts + 1
    WHERE id = $1
    RETURNING attempts
  `;
  const result = await client.query<{ attempts: number }>(query, [authCodeId]);
  return result.rows[0].attempts;
}

async function upsertUserDevice(client: PoolClient, email: string, deviceId: string): Promise<'ok' | 'conflict'> {
  const selectQuery = `
    SELECT email, device_id, last_seen
    FROM users
    WHERE email = $1
    FOR UPDATE
  `;
  const existing = await client.query<{ email: string; device_id: string; last_seen: Date }>(selectQuery, [email]);

  if (existing.rowCount === 0) {
    const insertQuery = `
      INSERT INTO users (email, device_id, last_seen)
      VALUES ($1, $2, NOW())
    `;
    await client.query(insertQuery, [email, deviceId]);
    return 'ok';
  }

  const user = existing.rows[0];
  if (user.device_id !== deviceId) {
    const activeThreshold = new Date(Date.now() - DEVICE_CONFLICT_WINDOW_MINUTES * 60 * 1000);
    if (new Date(user.last_seen) >= activeThreshold) {
      return 'conflict';
    }
  }

  const updateQuery = `
    UPDATE users
    SET device_id = $2,
        last_seen = NOW()
    WHERE email = $1
  `;
  await client.query(updateQuery, [email, deviceId]);
  return 'ok';
}

app.post('/auth/request-code', async (req: Request<unknown, unknown, RequestCodeBody>, res: Response) => {
  const emailInput = req.body?.email;
  if (typeof emailInput !== 'string' || emailInput.trim() === '') {
    return res.status(200).json(GENERIC_REQUEST_CODE_RESPONSE);
  }

  const email = normalizeEmail(emailInput);

  try {
    const outcome: Outcome = await withTransaction(async (client) => {
      await client.query("LOCK TABLE auth_codes IN ROW EXCLUSIVE MODE");  
      const licensed = await hasActiveLicense(client, email);
      if (!licensed) {
        return {
             status: 403 as const,
             body: { error: 'no_license' }, 
            };
      }

      const withinLimit = await checkRequestRateLimit(client, email);
      if (!withinLimit) {
        return { 
            status: 429 as const,
            body: { error: 'too_many_requests' },
        };
      }

      const code = generateCode();
      await storeAuthCode(client, email, hashSHA256(code));
      return { shouldSend: true, code };
    });
    // RECHEQUEAR
    if ( "status" in outcome && outcome.status === 429) {
      return res.status(429).json(outcome.body);
    }

    if ( "status" in outcome && outcome.status === 403) {
      return res.status(403).json(outcome.body);
    }
    if ("shouldSend" in outcome && outcome.shouldSend) {
      await sendEmail(email, outcome.code);
    }

    return res.status(200).json(GENERIC_REQUEST_CODE_RESPONSE);
  } catch (error) {
    console.error('request-code failed', error);
    return res.status(500).json({ error: 'internal_error' });
  }
});

app.post('/auth/verify-code', async (req: Request<unknown, unknown, VerifyCodeBody>, res: Response) => {
  const emailInput = req.body?.email;
  const codeInput = req.body?.code;
  const deviceIdInput = req.body?.device_id;

  if (
    typeof emailInput !== 'string' ||
    emailInput.trim() === '' ||
    typeof codeInput !== 'string' ||
    !/^\d{6}$/.test(codeInput) ||
    typeof deviceIdInput !== 'string' ||
    deviceIdInput.trim() === ''
  ) {
    return res.status(401).json({ error: 'invalid_credentials' });
  }

  const email = normalizeEmail(emailInput);
  const deviceId = deviceIdInput.trim();

  try {
    const result = await withTransaction(async (client) => {
      const licensed = await hasActiveLicense(client, email);
      if (!licensed) {
        return { status: 401 as const, body: { error: 'invalid_credentials' } };
      }

      const authCode = await getLatestAuthCodeForUpdate(client, email);
      if (!authCode) {
        return { status: 401 as const, body: { error: 'invalid_credentials' } };
      }

      if (authCode.blocked_until && new Date() < authCode.blocked_until) {
        return { status: 429 as const, body: { error: 'temporarily_blocked' } };
    }


      if ( authCode.expires_at <= new Date()) {
        return { status: 401 as const, body: { error: 'invalid_credentials' } };
      }

      if (hashSHA256(codeInput) !== authCode.code_hash) {
  const attempts = await incrementCodeAttempts(client, authCode.id);

  if (attempts >= MAX_VERIFY_ATTEMPTS) {
    await client.query(`
      UPDATE auth_codes
      SET blocked_until = NOW() + INTERVAL '10 minutes'
      WHERE id = $1
    `, [authCode.id]);
  }

  return { status: 401 as const, body: { error: 'invalid_code' } };
}

      const deviceStatus = await upsertUserDevice(client, email, deviceId);
      if (deviceStatus === 'conflict') {
        return { status: 409 as const, body: { error: 'device_conflict' } };
      }

      return {
        status: 200 as const,
        body: {
          ok: true,
          email,
          device_id: deviceId,
          verified_at: new Date().toISOString(),
        },
      };
    });

    return res.status(result.status).json(result.body);
  } catch (error) {
    console.error('verify-code failed', error);
    return res.status(500).json({ error: 'internal_error' });
  }
});

app.get('/health', async (_req, res) => {
  try {
    await pool.query('SELECT 1');
    res.status(200).json({ ok: true });
  } catch (error) {
    console.error('health check failed', error);
    res.status(500).json({ ok: false });
  }
});

const port = Number(process.env.PORT ?? 3000);
app.listen(port, () => {
  console.info(`Auth server listening on port ${port}`);
  console.info('Schema SQL:\n%s', SCHEMA_SQL.trim());
});

export {
  SCHEMA_SQL,
  app,
  checkRequestRateLimit,
  generateCode,
  hashSHA256,
  normalizeEmail,
  sendEmail,
};
