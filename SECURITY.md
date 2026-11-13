# Security Specification — Together

## 1. Security Philosophy & Threat Model

Together is a private scheduling and life-coordination mobile application built for couples. The security architecture operates on a **zero-trust client boundary** and **privacy-by-default** foundation.

### Primary Threat Vectors Mitigated
1. **Unauthorized Access**: Third parties or non-members attempting to read couple calendars, shared plans, or personal notes.
2. **In-Relationship Surveillance & Spying**: A partner attempting to inspect the private contents (medical appointments, surprises, personal therapy sessions) of the other partner's personal schedule.
3. **Impersonation & Privilege Escalation**: One partner attempting to modify, reschedule, or delete another partner's personal events.
4. **Data Leakage via Push Notifications**: Sensitive event titles, descriptions, or locations being transmitted in plaintext push payloads visible on lock screens.
5. **Orphaned / Stale Access**: A disconnected or former partner retaining access to historical cached events or future calendar feeds.

---

## 2. Authentication Boundaries

- **Identity Provider**: Firebase Authentication (Email/Password, Optional Google OAuth).
- **Session Verification**: The mobile client verifies active Firebase Auth tokens before initiating sensitive operations.
- **Account Isolation**: Each user account is strictly isolated in `users/{uid}`.
- **Session Termination**: Upon sign-out, local memory caches and `SharedPreferences` tokens are cleared immediately.

---

## 3. Data Classification & Privacy Architecture

| Classification | Data Elements | Visibility Rules | Storage & Transport Enforcement |
| :--- | :--- | :--- | :--- |
| **Personal Public** | Display name, avatar URL | Both partners in active couple | Read allowed by authenticated couple members |
| **Shared Event** | Event title, description, time, location, category | Both partners in active couple | Read allowed by authenticated couple members |
| **Private Event** | Personal private title, notes, venue | **Owner only** | Unmasked fields **never transmitted** to partner. Partner only receives a synthetic `busy_block` (startTime, endTime, status: busy). |
| **Couple Workspace** | Couple ID, members list, anniversary date | Exactly 2 verified members | Read and update restricted to `request.auth.uid in resource.data.members` |
| **Invitations** | Single-use 6-character code, expiration timestamp | Public read for validation; accepted by single user | Verified server-side via atomic transactions |

---

## 4. Firestore Security Rules Enforcement

Firestore rules enforce authorization server-side:
- `users/{userId}`: Readable by authenticated members; writable only by `request.auth.uid == userId`.
- `couples/{coupleId}`: Accessible strictly when `request.auth.uid in resource.data.members`.
- `events/{eventId}`:
  - Read: Allowed if `resource.data.ownerId == request.auth.uid` OR (`isCoupleMember(resource.data.coupleId) && resource.data.visibility == 'shared'`).
  - Create: Allowed if `request.resource.data.ownerId == request.auth.uid` AND `isCoupleMember(request.resource.data.coupleId)`.
  - Update: Allowed for the owner, or for couple members if the event is explicitly `shared`.
  - Delete: Strictly `resource.data.ownerId == request.auth.uid`.
- `notifications/{notificationId}`: Readable and writable strictly by the designated recipient (`request.auth.uid == resource.data.recipientId`).

---

## 5. Push Notification Privacy

Push notifications are dispatched through trusted backend triggers:
- Push payloads for private events **never include titles, notes, or locations**.
- Payload text is masked: `"Partner marked a private busy block"` with only the relevant time window.
- Device registration tokens (`fcmTokens`) are managed inside protected subcollections and rotated securely.

---

## 6. Account Deletion & Disconnection Protocol

1. **Disconnection / Leaving Workspace**:
   - Updates `couples/{coupleId}` status to `dissolved`.
   - Removes both user associations (`coupleId = null`, `partnerId = null`).
   - Revokes real-time Firestore listeners immediately.
   - Clears local cached partner data from SQLite/SharedPreferences.
2. **Account Deletion**:
   - Deletes personal user document from `users/{uid}`.
   - Deletes owned events from `events/`.
   - Dissolves couple space safely without corrupting or deleting the partner's independent account.

