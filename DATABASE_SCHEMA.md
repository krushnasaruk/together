# Database Schema Specification — Together

## 1. Overview & Principles

Together uses Google Cloud Firestore as its primary operational database. The schema is designed with the following mandatory architectural requirements:
1. **Bounded Documents**: Documents never contain unbounded arrays (e.g. events are distinct top-level documents, not embedded in a couple document).
2. **Strict Isolation & Privacy**: Events have visibility flags (`shared` vs `private`). Security rules prevent unauthorized reads, while clients sanitize private details for partners.
3. **Optimistic Locking & Versioning**: Every event has an integer `version` field incremented on updates to detect and resolve concurrent modifications.
4. **Server-Generated Timestamps**: Audit fields (`createdAt`, `updatedAt`) use `FieldValue.serverTimestamp()`.
5. **Timezone Awareness**: Events store raw UTC start/end timestamps along with the creator's IANA timezone string (e.g., `Asia/Kolkata`, `America/New_York`) to accurately expand recurrence rules.

---

## 2. Collections and Document Schemas

### A. `users/{userId}`
Represents an individual user account.

| Field Name | Type | Description |
| :--- | :--- | :--- |
| `uid` | `string` | Matches Firebase Authentication UID |
| `email` | `string` | User email address |
| `displayName` | `string` | User full or preferred name |
| `photoUrl` | `string?` | Optional profile image URL |
| `coupleId` | `string?` | ID of the active couple space (null if unpaired) |
| `partnerId` | `string?` | UID of the paired partner (null if unpaired) |
| `timezone` | `string` | User's local IANA timezone identifier |
| `fcmTokens` | `list<string>` | Active FCM registration tokens for devices |
| `notificationSettings` | `map` | User notification preferences |
| `notificationSettings.eventCreated` | `bool` | Push when partner creates an event (default: true) |
| `notificationSettings.eventUpdated` | `bool` | Push when partner updates an event (default: true) |
| `notificationSettings.eventCancelled` | `bool` | Push when partner cancels an event (default: true) |
| `notificationSettings.statusUpdates` | `bool` | Push for quick status changes (default: true) |
| `createdAt` | `timestamp` | Document creation timestamp |
| `updatedAt` | `timestamp` | Document last update timestamp |

---

### B. `couples/{coupleId}`
Represents a private couple workspace between two authenticated partners.

| Field Name | Type | Description |
| :--- | :--- | :--- |
| `id` | `string` | Unique couple ID |
| `members` | `list<string>` | Exactly two user UIDs: `[uid1, uid2]` |
| `creatorUid` | `string` | UID of the partner who initiated pairing |
| `anniversaryDate` | `timestamp?` | Optional relationship anniversary date |
| `status` | `string` | Status: `active`, `paused`, `dissolved` |
| `themePreferences` | `map` | Shared color/theme settings |
| `createdAt` | `timestamp` | Timestamp when couple was established |
| `updatedAt` | `timestamp` | Last update timestamp |

---

### C. `invitations/{invitationId}`
Single-use invitation codes generated to link two partners.

| Field Name | Type | Description |
| :--- | :--- | :--- |
| `id` | `string` | Unique invitation document ID |
| `code` | `string` | 6-8 character uppercase alphanumeric code (indexed) |
| `creatorUid` | `string` | UID of user generating the invite |
| `creatorName` | `string` | Display name of the creator for preview |
| `status` | `string` | `pending`, `accepted`, `expired`, `revoked` |
| `expiresAt` | `timestamp` | Expiration time (typically 48 hours from creation) |
| `acceptedByUid` | `string?` | UID of partner who accepted the invitation |
| `createdAt` | `timestamp` | Creation timestamp |

---

### D. `events/{eventId}`
Personal and shared calendar events.

| Field Name | Type | Description |
| :--- | :--- | :--- |
| `id` | `string` | Unique event ID |
| `coupleId` | `string` | ID of the couple workspace |
| `ownerId` | `string` | UID of the user who owns/created the event |
| `title` | `string` | Event title (masked if private for partner) |
| `description` | `string?` | Optional details/notes |
| `location` | `string?` | Optional physical address or venue |
| `startTime` | `timestamp` | Event start date & time (UTC) |
| `endTime` | `timestamp` | Event end date & time (UTC) |
| `isAllDay` | `bool` | Flag for all-day events |
| `category` | `string` | `work`, `college`, `study`, `personal`, `family`, `social`, `travel`, `other` |
| `visibility` | `string` | `shared` (visible to partner) or `private` (masked busy block) |
| `status` | `string` | `confirmed`, `tentative`, `completed`, `cancelled` |
| `recurrenceRule` | `string?` | RFC 5545 RRULE string (e.g. `FREQ=WEEKLY;BYDAY=MO,WE`) |
| `timezone` | `string` | IANA timezone in which event was scheduled |
| `version` | `int` | Monotonically increasing version number for optimistic locking |
| `reminderMinutes` | `list<int>?`| Reminder offsets before start (e.g. `[15, 60]`) |
| `createdAt` | `timestamp` | Creation server timestamp |
| `updatedAt` | `timestamp` | Last update server timestamp |

---

### E. `notifications/{notificationId}`
In-app notification records for life updates and event notifications.

| Field Name | Type | Description |
| :--- | :--- | :--- |
| `id` | `string` | Unique notification ID |
| `recipientId` | `string` | UID of the user receiving the notification |
| `senderId` | `string` | UID of the partner who triggered the event |
| `coupleId` | `string` | ID of the couple workspace |
| `type` | `string` | `event_created`, `event_updated`, `event_cancelled`, `status_update` |
| `title` | `string` | Formatted notification headline |
| `body` | `string` | Notification message text |
| `entityId` | `string?` | Reference event ID or status ID |
| `isRead` | `bool` | Whether recipient has opened/read the notification |
| `createdAt` | `timestamp` | Timestamp notification was generated |

---

### F. `status_updates/{statusId}`
Voluntary quick status updates (no continuous GPS tracking).

| Field Name | Type | Description |
| :--- | :--- | :--- |
| `id` | `string` | Unique status update ID |
| `userId` | `string` | UID of the user who set the status |
| `coupleId` | `string` | Couple ID |
| `statusPreset` | `string` | `on_my_way`, `running_late`, `meeting_extended`, `free_now`, `taking_a_break`, `need_focus` |
| `customMessage` | `string?`| Optional short note |
| `createdAt` | `timestamp` | Creation timestamp |
| `expiresAt` | `timestamp` | Expiry timestamp (e.g., 2 hours from creation) |

---

## 3. Firestore Indexes

To support high-performance filtered range queries on events without unbounded reads, the following composite indexes are specified:

1. **Events Query by Couple and Date Range**:
   - Collection: `events`
   - Fields: `coupleId` ASC, `startTime` ASC
2. **Events Query by Owner, Couple, and Date Range**:
   - Collection: `events`
   - Fields: `coupleId` ASC, `ownerId` ASC, `startTime` ASC
3. **Notifications by Recipient and Date**:
   - Collection: `notifications`
   - Fields: `recipientId` ASC, `createdAt` DESC
4. **Invitations Lookup by Code**:
   - Collection: `invitations`
   - Fields: `code` ASC, `status` ASC
