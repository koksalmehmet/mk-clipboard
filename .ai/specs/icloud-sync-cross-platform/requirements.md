# Requirements

## User Stories

1. **Cross-device clipboard continuity**
   - *As a* power user with both macOS and iOS devices,
   - *I want* my clipboard history to sync automatically via iCloud,
   - *So that* I can copy on one device and paste from the same history on another without manual steps.

2. **Trustworthy sync visibility**
   - *As a* security-conscious user,
   - *I want* clear indicators showing when clipboard items are synced or pending upload,
   - *So that* I have confidence that my data is stored securely and is available across devices.

3. **Granular sync control**
   - *As a* user managing sensitive information,
   - *I want* the ability to exclude specific items or categories from iCloud sync and to pause/resume syncing,
   - *So that* I can prevent private data from leaving a device when necessary.

4. **Reliable offline experience**
   - *As a* mobile user who is frequently offline,
   - *I want* clipboard history to be cached locally and automatically reconciled with iCloud once I reconnect,
   - *So that* I never lose clipboard context even without connectivity.

5. **Simple onboarding**
   - *As a* first-time user enabling iCloud sync,
   - *I want* an onboarding flow that guides me through permissions, first sync, and any privacy implications,
   - *So that* I understand what is happening and can make informed choices.

## Acceptance Criteria

### A. Cross-platform synchronization
- macOS and iOS clients both authenticate with the same iCloud container using the user’s Apple ID.
- A clipboard item copied on one platform appears on the other platform within 10 seconds when both are online.
- When offline, items queue locally and sync automatically within 10 seconds of reconnection.
- Conflicts are resolved using last-modified timestamps; the newest version prevails.

### B. Sync status transparency
- Each clipboard entry shows a sync badge in history list: `Synced`, `Pending`, or `Failed`.
- Pending uploads are retried with exponential backoff up to 5 attempts before displaying `Failed` status and surfacing an actionable retry option.
- A menu item/button exposes last successful sync timestamp per device.

### C. Selective sync controls
- User can toggle global “iCloud Sync” on/off from preferences/settings.
- User can mark individual clipboard items as “local only”; these never leave the originating device.
- Preferences include an optional rule-based filter (e.g., content type, source app) to exclude items from syncing.
- Sync pause/resume is instantaneous and persists across app restarts.

### D. Offline durability
- Clipboard history remains available locally regardless of network state.
- Sync queue persists across app relaunches and device restarts.
- Failed sync attempts generate non-blocking notifications and appear in an activity log.

### E. Onboarding and permissions
- First launch after update prompts user to enable iCloud sync with clear explanation of data usage and opt-out option.
- On macOS, necessary entitlements and CloudKit container permissions are requested once and stored.
- On iOS, app gracefully handles cases where iCloud is disabled by providing fallback instructions and disabling sync UI until resolved.
- Onboarding flow records completion status so it is not shown again unless sync is disabled and re-enabled.

