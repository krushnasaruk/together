import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

/**
 * Triggers on notification creation in Firestore and delivers trusted FCM pushes.
 */
export const onNotificationCreated = functions.firestore
  .document("notifications/{notificationId}")
  .onCreate(async (snapshot) => {
    const data = snapshot.data();
    if (!data || !data.recipientId) return;

    // Fetch user device tokens
    const userDoc = await db.collection("users").doc(data.recipientId).get();
    const tokens: string[] = userDoc.data()?.fcmTokens || [];

    if (tokens.length === 0) return;

    const payload: admin.messaging.MulticastMessage = {
      tokens,
      notification: {
        title: data.title,
        body: data.body,
      },
      data: {
        notificationId: snapshot.id,
        entityId: data.entityId || "",
        type: data.type || "",
      },
      android: {
        priority: "high",
        notification: {
          channelId: "together_updates",
        },
      },
      apns: {
        payload: {
          aps: {
            badge: 1,
            sound: "default",
          },
        },
      },
    };

    try {
      const response = await admin.messaging().sendEachForMulticast(payload);
      // Clean up invalid tokens if any
      const invalidTokens: string[] = [];
      response.responses.forEach((res, idx) => {
        if (!res.success && res.error?.code === "messaging/registration-token-not-registered") {
          invalidTokens.push(tokens[idx]);
        }
      });

      if (invalidTokens.length > 0) {
        await userDoc.ref.update({
          fcmTokens: admin.firestore.FieldValue.arrayRemove(...invalidTokens),
        });
      }
    } catch (err) {
      functions.logger.error("Error dispatching FCM push:", err);
    }
  });

