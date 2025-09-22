import XCTest
@testable import SharedClipboardKit

final class ClipboardRecordTests: XCTestCase {
  func test_initializerSetsProvidedValuesAndDefaults() throws {
    let fixedID = UUID(uuidString: "6FCF905F-64B7-4A60-9B85-C6CF5A590C9C")!
    let createdAt = Date(timeIntervalSince1970: 1_700_000_000)
    let record = ClipboardRecord(
      id: fixedID,
      contentData: Data("Hello, world".utf8),
      contentType: "public.plain-text",
      sourceApp: "com.example.editor",
      createdAt: createdAt,
      updatedAt: nil,
      deviceId: "device-001",
      syncState: .pending,
      isPinned: false,
      isLocalOnly: false,
      filtersHash: "text/plain",
      cloudKitRecordID: nil,
      lastSyncError: nil
    )

    XCTAssertEqual(record.id, fixedID)
    XCTAssertEqual(record.contentData, Data("Hello, world".utf8))
    XCTAssertEqual(record.contentType, "public.plain-text")
    XCTAssertEqual(record.sourceApp, "com.example.editor")
    XCTAssertEqual(record.createdAt, createdAt)
    XCTAssertEqual(record.updatedAt, createdAt)
    XCTAssertEqual(record.deviceId, "device-001")
    XCTAssertEqual(record.syncState, .pending)
    XCTAssertFalse(record.isPinned)
    XCTAssertFalse(record.isLocalOnly)
    XCTAssertNil(record.cloudKitRecordID)
    XCTAssertNil(record.lastSyncError)
  }

  func test_encodeForCloudProducesDeterministicPayload() throws {
    let record = ClipboardRecord(
      id: UUID(uuidString: "A6E81B8C-9BAD-4F75-B568-59D9A5C43210")!,
      contentData: Data("payload".utf8),
      contentType: "public.plain-text",
      sourceApp: "com.example.clipboard",
      createdAt: Date(timeIntervalSince1970: 1_699_123_456),
      updatedAt: Date(timeIntervalSince1970: 1_699_223_456),
      deviceId: "device-1234",
      syncState: .pending,
      isPinned: true,
      isLocalOnly: false,
      filtersHash: "text/plain",
      cloudKitRecordID: "record-abc",
      lastSyncError: nil
    )

    let data = try record.encodeForCloud()
    let jsonAny = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

    XCTAssertEqual(jsonAny["id"] as? String, record.id.uuidString)
    XCTAssertEqual(jsonAny["contentType"] as? String, "public.plain-text")
    XCTAssertEqual(jsonAny["sourceApp"] as? String, "com.example.clipboard")
    XCTAssertEqual(jsonAny["deviceId"] as? String, "device-1234")
    XCTAssertEqual(jsonAny["isPinned"] as? Bool, true)
    XCTAssertEqual(jsonAny["isLocalOnly"] as? Bool, false)
    XCTAssertEqual(jsonAny["schemaVersion"] as? Int, 1)
    XCTAssertEqual(jsonAny["contentBase64"] as? String, record.contentData.base64EncodedString())

    let updatedAt = try XCTUnwrap(jsonAny["updatedAt"] as? Double)
    XCTAssertEqual(updatedAt, record.updatedAt.timeIntervalSince1970, accuracy: 0.0001)
    let createdAt = try XCTUnwrap(jsonAny["createdAt"] as? Double)
    XCTAssertEqual(createdAt, record.createdAt.timeIntervalSince1970, accuracy: 0.0001)
  }

  func test_encodeForCloudThrowsWhenLocalOnly() {
    let record = ClipboardRecord(
      id: UUID(),
      contentData: Data("secret".utf8),
      contentType: "public.plain-text",
      sourceApp: nil,
      createdAt: Date(),
      updatedAt: nil,
      deviceId: "device-999",
      syncState: .localOnly,
      isPinned: false,
      isLocalOnly: true,
      filtersHash: nil,
      cloudKitRecordID: nil,
      lastSyncError: nil
    )

    XCTAssertThrowsError(try record.encodeForCloud()) { error in
      guard case ClipboardRecord.SerializationError.localOnly = error else {
        XCTFail("Expected localOnly error, got \(error)")
        return
      }
    }
  }
}
