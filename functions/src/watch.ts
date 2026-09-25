import * as admin from "firebase-admin";
import { gmailClient, gmailTopicName } from "./gmail";

const SYNC_DOC = "system/gmailSync";

/**
 * Registers (or renews) the Gmail push subscription for the intake
 * mailbox. `users.watch()` expires after 7 days, so this must be called
 * at least that often — the scheduled `renewGmailWatch` function does so
 * daily (see functions/src/index.ts).
 *
 * On the very first call for this mailbox, also seeds the sync cursor
 * (`system/gmailSync.lastHistoryId`) from the watch response, so
 * `syncNewMessages` starts from "now" instead of replaying the mailbox's
 * entire pre-existing history as new requests.
 */
export async function renewWatch(): Promise<{ historyId: string; expiration: string | null }> {
  const gmail = gmailClient();
  const response = await gmail.users.watch({
    userId: "me",
    requestBody: {
      topicName: gmailTopicName(),
      labelIds: ["INBOX"],
    },
  });

  const historyId = response.data.historyId;
  if (!historyId) throw new Error("Gmail watch() response had no historyId.");

  const syncDocRef = admin.firestore().doc(SYNC_DOC);
  const syncDoc = await syncDocRef.get();
  await syncDocRef.set(
    {
      watchHistoryId: historyId,
      watchExpiration: response.data.expiration ?? null,
      watchRenewedAt: admin.firestore.FieldValue.serverTimestamp(),
      // Only set on the very first watch — afterwards, `syncNewMessages`
      // owns this field.
      ...(syncDoc.data()?.lastHistoryId ? {} : { lastHistoryId: historyId }),
    },
    { merge: true },
  );

  return { historyId, expiration: response.data.expiration ?? null };
}
