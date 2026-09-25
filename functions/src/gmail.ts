import { google, gmail_v1 } from "googleapis";

/**
 * Domain-wide delegation: a dedicated GCP service account impersonates the
 * intake mailbox (`GMAIL_MAILBOX`), authorized in the Workspace Admin
 * console for the readonly scope (see functions/README.md's one-time
 * setup — this authorization can't be done from code).
 */
const SCOPES = ["https://www.googleapis.com/auth/gmail.readonly"];

export interface DelegatedServiceAccountKey {
  client_email: string;
  private_key: string;
}

let cachedClient: gmail_v1.Gmail | null = null;
let cachedKeyRaw: string | null = null;

/**
 * Builds (and memoizes, for the life of the function instance) an
 * authenticated Gmail API client for `GMAIL_MAILBOX`. Reads its
 * credentials from the `GMAIL_DELEGATED_SA_KEY` secret and the
 * `GMAIL_MAILBOX` env var on every call so a changed secret/env value
 * (new deploy) invalidates the cache automatically.
 */
export function gmailClient(): gmail_v1.Gmail {
  const keyRaw = process.env.GMAIL_DELEGATED_SA_KEY;
  const mailbox = process.env.GMAIL_MAILBOX;
  if (!keyRaw) throw new Error("GMAIL_DELEGATED_SA_KEY secret is not set.");
  if (!mailbox) throw new Error("GMAIL_MAILBOX env var is not set.");

  if (cachedClient && cachedKeyRaw === keyRaw) return cachedClient;

  const key = JSON.parse(keyRaw) as DelegatedServiceAccountKey;
  const auth = new google.auth.JWT({
    email: key.client_email,
    key: key.private_key,
    scopes: SCOPES,
    subject: mailbox,
  });

  cachedClient = google.gmail({ version: "v1", auth });
  cachedKeyRaw = keyRaw;
  return cachedClient;
}

/** The Pub/Sub topic `users.watch()` publishes new-mail notifications to. */
export function gmailTopicName(): string {
  const topic = process.env.GMAIL_PUBSUB_TOPIC;
  if (!topic) throw new Error("GMAIL_PUBSUB_TOPIC env var is not set.");
  return topic;
}
