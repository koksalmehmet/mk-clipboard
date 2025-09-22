# Testing Strategy

## Testing Pyramid
- **Unit Tests (60%)**: Validate local persistence, sync state transitions, filter logic, and CloudKit record serialization/deserialization in isolation.
- **Integration Tests (30%)**: Exercise `CloudSyncCoordinator` with mocked CloudKit operations, ensuring queue processing, conflict resolution, and retry policies behave as expected across macOS/iOS targets.
- **End-to-End Tests (10%)**: UI-driven flows verifying onboarding, sync status presentation, and cross-device data propagation using CloudKit container in a staging environment.

## Test Environments
- **Local Simulator/Host**: XCTest with injected mocks for CloudKit, network, and feature flags.
- **CI Pipeline**: macOS/iOS runners configured with CloudKit staging container credentials and deterministic data fixtures.
- **Staging CloudKit Container**: Dedicated schema mirroring production for E2E validation without impacting live data.

## Key Test Scenarios

### Unit
1. `ClipboardStore` saves items with correct metadata, respects `isLocalOnly` flag, and enqueues sync jobs.
2. `SyncQueue` persists across app relaunches and resumes processing from last checkpoint.
3. `CloudSyncCoordinator` converts `ClipboardRecord` to `CKRecord` preserving timestamps, device IDs, and pinned state.
4. Filter engine correctly excludes items based on content type/source rules and sets `syncState = .localOnly`.
5. Retry policy applies exponential backoff and caps attempts at five, marking `syncState = .failed` afterward.

### Integration
1. Outbound sync: simulate network success/failure to verify state transitions `pending -> synced` or `pending -> failed`.
2. Inbound delta processing: given server change token and mocked CloudKit responses, ensure new items insert/update locally and conflicts resolve using timestamps.
3. Offline recovery: disable network, enqueue multiple items, restore network and confirm queue drains with correct ordering and latencies.
4. Sync pause/resume: toggle feature flag mid-queue and ensure operations halt/resume without data loss.
5. Activity log population: failed attempts appear with correct metadata and propagate to UI observers.

### End-to-End
1. Fresh install onboarding: enable iCloud sync, accept permissions, verify first item syncs to staging container and status badge shows `Synced`.
2. Cross-device propagation: copy on macOS, confirm appearance on iOS within SLA and vice versa using real CloudKit.
3. Selective sync: mark item as local-only on macOS, ensure it never appears on iOS and remains flagged locally.
4. Offline iOS usage: capture items while offline, re-enable connectivity, confirm automatic sync and badge updates.
5. Failure recovery UX: induce CloudKit quota error, verify `Failed` status, actionable retry button, and subsequent success after clearing quota.

## Tooling & Automation
- Use `XCTest` + `@MainActor` isolation for shared package tests.
- Introduce CloudKit mock layer for deterministic integration tests (e.g., protocol-backed adapters).
- Leverage `XCUITest` for onboarding and sync status flows; consider snapshot testing for badges.
- Instrument CI to run unit/integration suites on every PR; schedule nightly E2E runs against staging.

## Metrics & Monitoring
- Track sync latency (enqueue -> synced), failure rate, and retry counts via structured logs in test runs.
- Ensure coverage reports highlight `SharedClipboardKit` module at >= 85% line coverage.

