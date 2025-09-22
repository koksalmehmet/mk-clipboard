# Design

## Overview
Implement a cross-platform clipboard history synchronisation layer using CloudKit so that macOS and iOS clients share a common dataset while preserving the existing local-first behaviour. The solution introduces a reusable Swift package (`SharedClipboardKit`) that encapsulates models, persistence, sync orchestration, and feature flagging. Platform targets depend on this package and supply adapters for platform-specific capabilities (pasteboard access, notifications, background execution).

## Architecture

### Components
- **SharedClipboardKit (Swift Package)**
  - `ClipboardItem`: value type backed by SwiftData locally and CloudKit remotely.
  - `SyncState`: enum describing `synced`, `pending`, `failed`, `localOnly`.
  - `ClipboardStore`: facade managing local persistence, sync metadata, and queries.
  - `CloudSyncCoordinator`: orchestrates CloudKit operations and conflict resolution via timestamps + device IDs.
  - `SyncQueue`: durable queue of outbound/inbound operations persisted to disk for offline replay.
  - `FeatureFlags`: exposes `isCloudSyncEnabled` backed by Defaults/NSUserDefaults + server-driven overrides.
  - Protocols for platform services: `PasteboardService`, `Notifier`, `BackgroundScheduler`, `Logger`.

- **macOS Target (Maccy App)**
  - Implements protocols with AppKit types (`NSPasteboard`, `NSUserActivity`, `DispatchSourceTimer`).
  - Integrates status badging in existing SwiftUI views (`HistoryItemView`) using `SyncState`.
  - Adds Preferences pane controls for global toggle, filters, and per-item controls.

- **iOS Target (new)**
  - Uses `UIPasteboard`, background tasks, and push notifications.
  - Presents onboarding flow via SwiftUI navigation and Settings integration.

### Data Flow
1. Clipboard events captured via platform-specific `PasteboardService` feed into `ClipboardStore`.
2. `ClipboardStore` saves items locally with metadata (timestamp, device ID, filters, sync state) and enqueues sync jobs.
3. `CloudSyncCoordinator` processes outbound queue: serialises records to CloudKit `CKRecord` objects, submits via `CKModifyRecordsOperation`, and updates states on success/failure.
4. Inbound sync uses CloudKit subscriptions to receive pushes, plus periodic fetch-all deltas using server change tokens.
5. UI observes `ClipboardStore` publishers to reflect real-time changes and sync status badges.

## Data Model

### Local Persistence (SwiftData)
- **Entity `ClipboardRecord`**
  - `id: UUID`
  - `contentData: Data` (JSON or archived multi-type payload)
  - `contentType: String`
  - `sourceApp: String?`
  - `createdAt: Date`
  - `updatedAt: Date`
  - `deviceId: String`
  - `syncState: SyncState`
  - `isPinned: Bool`
  - `isLocalOnly: Bool`
  - `filtersHash: String?` (computed from exclusion rules applied when created)
  - `cloudKitRecordID: String?`
  - `lastSyncError: String?`

### Remote Schema (CloudKit public/private database)
- **Record Type `ClipboardItem`**
  - `id (RecordName)` mirrors local UUID string.
  - `payload` (Encrypted data blob; 1MB limit) storing same content as local `contentData`.
  - `contentType`, `sourceApp` (optional strings, trimmed to safe lengths).
  - `createdAt`, `updatedAt` (Date fields).
  - `deviceId` (String).
  - `isPinned` (Boolean).
  - `schemaVersion` (Int) for migrations.

Indexes: sort by `updatedAt`. Set `desiredKeys` to minimise payload when only metadata required.

### Sync Metadata
- `ServerChangeToken` stored per device so CloudKit delta fetch resumes correctly.
- `SyncAttempt` log entries persisted for activity log UI: includes `timestamp`, `itemId`, `direction`, `result`.

## Synchronisation Strategy
- **Outbound**: Batch items in groups of <= 100 per CloudKit limits; throttle to avoid rate limiting.
- **Inbound**: Register `CKQuerySubscription` for `ClipboardItem` changes. On notification, fetch delta using stored change token.
- **Conflict Resolution**: Compare `updatedAt`; newest wins. If equal, prefer entry with higher `deviceId` lexical order to maintain determinism. Merge pinned flag using logical OR.
- **Retry Policy**: Exponential backoff with jitter for recoverable errors. After 5 attempts mark `syncState = .failed` and surface actionable retry.
- **Local-only Filters**: Before enqueueing outbound sync the `ClipboardStore` checks filter rules; if flagged the item is marked `isLocalOnly` and bypasses CloudKit.

## Platform-specific Considerations

### macOS
- Update `HistoryListView` to display sync badge; use `TimelineView` or `async` updates to reflect changes quickly.
- Preferences pane adds toggles for iCloud sync, filter rules, and activity log section.
- Use `NSBackgroundActivityScheduler` for periodic pulls when app is idle.
- Ensure menu bar UI reflects last sync timestamp from `CloudSyncCoordinator`.

### iOS
- New SwiftUI app target using `WindowGroup` hosting shared views adapted for touch.
- Background processing via `BGAppRefreshTask` to fetch CloudKit deltas.
- Onboarding flow triggered post-install / update, storing completion flag in shared defaults.
- Provide Share Sheet integration to copy/paste quickly.

## Security & Privacy
- Use CloudKit private database to ensure user-only access.
- Enable data encryption at rest/in transit (automatic with CloudKit).
- Store sensitive payloads using Apple-provided secure storage; avoid custom encryption unless mandated.
- Respect “local-only” flag by never serialising such entries for outbound sync.

## Error Handling & Observability
- Structured logging (os_log) scoped per component with categories (`sync`, `cloudkit`, `filters`).
- Synchronisation failures bubble up via `SyncStatusPublisher` for UI and stored in activity log.
- Integrate crash reporting markers around CloudKit operations to aid diagnostics.

## Deployment Strategy
- Wrap the entire feature behind a `Defaults` flag `icloudSyncEnabled` defaulting to `false` for existing users.
- Provide staged rollout: developer/internal builds with debug flag, then release controlled via remote config (e.g., CloudKit key-value store) enabling feature per Apple ID cohort.
- Include migration to seed `deviceId` and existing history entries before allowing outbound sync.
- Ensure app store release notes communicate optional nature; show onboarding gating to prevent accidental opt-in.

