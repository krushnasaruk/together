import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

/**
 * Validates and accepts a single-use couple invitation code atomically.
 * Enforces:
 * - Single-use token invalidation
 * - Expiration check (48h)
 * - One-couple constraint
 */
export const acceptInvitation = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated.");
  }

  const { code } = data;
  const acceptingUid = context.auth.uid;

  if (!code || typeof code !== "string") {
    throw new functions.https.HttpsError("invalid-argument", "Valid code is required.");
  }

  return db.runTransaction(async (transaction) => {
    // 1. Check if accepting user is already paired
    const userDocRef = db.collection("users").doc(acceptingUid);
    const userDoc = await transaction.get(userDocRef);
    if (userDoc.exists && userDoc.data()?.coupleId) {
      throw new functions.https.HttpsError("failed-precondition", "You already belong to a couple workspace.");
    }

    // 2. Query invitation by code
    const inviteQuery = db.collection("invitations")
      .where("code", "==", code.trim().toUpperCase())
      .where("status", "==", "pending")
      .limit(1);

    const inviteSnap = await transaction.get(inviteQuery);
    if (inviteSnap.empty) {
      throw new functions.https.HttpsError("not-found", "Invitation code is invalid or has already been used.");
    }

    const inviteDoc = inviteSnap.docs[0];
    const inviteData = inviteDoc.data();

    // 3. Verify expiration
    const expiresAt = inviteData.expiresAt.toDate();
    if (new Date() > expiresAt) {
      transaction.update(inviteDoc.ref, { status: "expired" });
      throw new functions.https.HttpsError("deadline-exceeded", "Invitation code has expired.");
    }

    // Prevent creator from pairing with themselves
    if (inviteData.creatorUid === acceptingUid) {
      throw new functions.https.HttpsError("invalid-argument", "Cannot accept your own invitation.");
    }

    // 4. Create new couple workspace
    const coupleRef = db.collection("couples").doc();
    transaction.set(coupleRef, {
      id: coupleRef.id,
      members: [inviteData.creatorUid, acceptingUid],
      creatorUid: inviteData.creatorUid,
      status: "active",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 5. Invalidate invitation
    transaction.update(inviteDoc.ref, {
      status: "accepted",
      acceptedByUid: acceptingUid,
      acceptedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 6. Update both user documents with coupleId and partnerId
    transaction.update(db.collection("users").doc(acceptingUid), {
      coupleId: coupleRef.id,
      partnerId: inviteData.creatorUid,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    transaction.update(db.collection("users").doc(inviteData.creatorUid), {
      coupleId: coupleRef.id,
      partnerId: acceptingUid,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true, coupleId: coupleRef.id };
  });
});

