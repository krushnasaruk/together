import * as admin from "firebase-admin";

admin.initializeApp();

export { acceptInvitation } from "./invitations/invitation_handler";
export { onEventWritten } from "./events/event_triggers";
export { onNotificationCreated } from "./notifications/push_dispatcher";

