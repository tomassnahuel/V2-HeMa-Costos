
/*declare module 'express' {
  export type Request<TParams = unknown, TResBody = unknown, TReqBody = unknown> = {
    body?: TReqBody;
  };

  export type Response = {
    status(code: number): Response;
    json(body: unknown): Response;
  };

  export type Handler = (req: Request<any, any, any>, res: Response) => unknown;

  type ExpressApp = {
    use(handler: unknown): void;
    post(path: string, handler: Handler): void;
    get(path: string, handler: Handler): void;
    listen(port: number, handler?: () => void): void;
  };

  type ExpressFactory = (() => ExpressApp) & {
    json(): Handler;
  };

  const express: ExpressFactory;
  export default express;
}

declare module 'pg' {
  export type QueryResult<TRow = Record<string, unknown>> = {
    rowCount: number;
    rows: TRow[];
  };

  export interface PoolClient {
    query<TRow = Record<string, unknown>>(queryText: string, values?: unknown[]): Promise<QueryResult<TRow>>;
    release(): void;
  }

  export class Pool {
    constructor(config?: { connectionString?: string });
    connect(): Promise<PoolClient>;
    query<TRow = Record<string, unknown>>(queryText: string, values?: unknown[]): Promise<QueryResult<TRow>>;
  }
}

declare module 'node:crypto' {
  const crypto: {
    createHash(algorithm: string): {
      update(value: string, inputEncoding?: string): { digest(encoding: string): string };
      digest(encoding: string): string;
    };
    randomInt(min: number, max: number): number;
  };

  export default crypto;
}

declare const process: { env: Record<string, string | undefined> };
*/