import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

/**
 * Triggers when a calendar event is created or updated.
 * Automatically dispatches partner notifications with strict privacy enforcement.
 */
export const onEventWritten = functions.firestore
  .document("events/{eventId}")
  .onWrite(async (change, context) => {
    const afterData = change.after.exists ? change.after.data() : null;
    const beforeData = change.before.exists ? change.before.data() : null;

    if (!afterData && !beforeData) return; // No change

    const coupleId = afterData ? afterData.coupleId : beforeData?.coupleId;
    const ownerId = afterData ? afterData.ownerId : beforeData?.ownerId;

    if (!coupleId || !ownerId) return;

    // Fetch couple to find partner UID
    const coupleDoc = await db.collection("couples").doc(coupleId).get();
    if (!coupleDoc.exists) return;

    const members: string[] = coupleDoc.data()?.members || [];
    const recipientId = members.find((uid) => uid !== ownerId);
    if (!recipientId) return;

    const ownerUserDoc = await db.collection("users").doc(ownerId).get();
    const ownerName = ownerUserDoc.data()?.displayName || "Partner";

    let notifType = "event_updated";
    let notifTitle = "Schedule Updated";
    let notifBody = `${ownerName} updated an event on the shared calendar.`;

    // 1. Deletion
    if (!afterData && beforeData) {
      notifType = "event_deleted";
      notifTitle = "Event Removed";
      notifBody = `${ownerName} removed an event from the schedule.`;
    }
    // 2. Creation
    else if (afterData && !beforeData) {
      notifType = "event_created";
      const isPrivate = afterData.visibility === "private";
      notifTitle = isPrivate ? "Busy Block Scheduled" : `New: ${afterData.title}`;
      notifBody = isPrivate
        ? `${ownerName} scheduled a private busy block.`
        : `${ownerName} scheduled "${afterData.title}".`;
    }
    // 3. Update
    else if (afterData && beforeData) {
      const isPrivate = afterData.visibility === "private";
      notifTitle = isPrivate ? "Schedule Rescheduled" : `Updated: ${afterData.title}`;
      notifBody = isPrivate
        ? `${ownerName} adjusted their busy schedule.`
        : `${ownerName} updated event details.`;
    }

    // Write in-app notification document
    await db.collection("notifications").add({
      recipientId,
      senderId: ownerId,
      senderName: ownerName,
      coupleId,
      type: notifType,
      title: notifTitle,
      body: notifBody,
      entityId: context.params.eventId,
      isRead: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

