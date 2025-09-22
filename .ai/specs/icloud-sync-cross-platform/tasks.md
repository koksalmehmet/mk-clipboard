# Tasks

## Specification Acceptance
[x] 0. Confirm specification lock-in after approvals.

## Implementation Plan (TDD)

### SharedClipboardKit Setup
[x] 1. (Red) Add failing unit tests describing `ClipboardRecord` SwiftData schema & serialization behavior.
[x] 2. (Green) Implement minimum `ClipboardRecord` model and persistence layer to pass tests.
[ ] 3. (Refactor) Extract common utilities and ensure schema versioning hooks are in place.

### Sync Queue & Filters
[ ] 4. (Red) Write failing tests for `SyncQueue` durability across relaunch and backlog ordering.
[ ] 5. (Green) Implement `SyncQueue` persistence + resume logic to satisfy tests.
[ ] 6. (Red) Write failing tests for filter rules producing `isLocalOnly` state and exclusion behavior.
[ ] 7. (Green) Implement filter engine honoring rules and update existing tests.
[ ] 8. (Refactor) Optimize queue/filter code paths for clarity and performance.

### CloudSyncCoordinator
[ ] 9. (Red) Author failing integration tests simulating outbound sync transitions `pending -> synced/failed`.
[ ] 10. (Green) Implement CloudKit adapter and coordinator to satisfy outbound tests.
[ ] 11. (Red) Write failing integration tests for inbound delta handling and conflict resolution.
[ ] 12. (Green) Implement delta fetch logic, conflict resolution, and change-token persistence.
[ ] 13. (Refactor) Harden retry policy with exponential backoff and jitter.

### Platform Integrations
[ ] 14. (Red) Add failing macOS integration test for UI badge reflecting sync states.
[ ] 15. (Green) Update macOS SwiftUI views and preferences pane to satisfy test and hook into coordinator.
[ ] 16. (Red) Add failing iOS integration test for onboarding flow + sync toggle state persistence.
[ ] 17. (Green) Implement iOS target UI, onboarding, and background task scheduling.
[ ] 18. (Refactor) Unify shared view components and ensure accessibility adjustments across platforms.

### End-to-End Validation
[ ] 19. (Red) Create E2E test script verifying cross-device propagation via staging CloudKit container.
[ ] 20. (Green) Implement staging environment configuration + automated script to pass E2E test.
[ ] 21. (Refactor) Review logs/metrics collection, adjust thresholds, and finalise activity log integration.

## Wrap-up
[ ] 22. Update documentation, release notes, and feature flag defaults per deployment strategy.
[ ] 23. Conduct final manual exploratory testing checklist across macOS & iOS.
[ ] 24. Prepare PR summary referencing spec and test results.

