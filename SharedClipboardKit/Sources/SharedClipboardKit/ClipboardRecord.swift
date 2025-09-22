import Foundation
import SwiftData

public enum SyncState: String, Codable, Sendable {
  case pending
  case synced
  case failed
  case localOnly
}

@Model
public final class ClipboardRecord {
  public enum SerializationError: Error {
    case localOnly
  }

  @Attribute(.unique) public var id: UUID
  public var contentData: Data
  public var contentType: String
  public var sourceApp: String?
  public var createdAt: Date
  public var updatedAt: Date
  public var deviceId: String
  public var syncState: SyncState
  public var isPinned: Bool
  public var isLocalOnly: Bool
  public var filtersHash: String?
  public var cloudKitRecordID: String?
  public var lastSyncError: String?

  public init(
    id: UUID = UUID(),
    contentData: Data,
    contentType: String,
    sourceApp: String?,
    createdAt: Date = Date(),
    updatedAt: Date? = nil,
    deviceId: String,
    syncState: SyncState = .pending,
    isPinned: Bool = false,
    isLocalOnly: Bool = false,
    filtersHash: String? = nil,
    cloudKitRecordID: String? = nil,
    lastSyncError: String? = nil
  ) {
    self.id = id
    self.contentData = contentData
    self.contentType = contentType
    self.sourceApp = sourceApp
    self.createdAt = createdAt
    self.updatedAt = updatedAt ?? createdAt
    self.deviceId = deviceId
    self.syncState = syncState
    self.isPinned = isPinned
    self.isLocalOnly = isLocalOnly
    self.filtersHash = filtersHash
    self.cloudKitRecordID = cloudKitRecordID
    self.lastSyncError = lastSyncError
  }

  public func encodeForCloud(schemaVersion: Int = 1) throws -> Data {
    guard isLocalOnly == false && syncState != .localOnly else {
      throw SerializationError.localOnly
    }

    var payload: [String: Any] = [
      "schemaVersion": schemaVersion,
      "id": id.uuidString,
      "contentBase64": contentData.base64EncodedString(),
      "contentType": contentType,
      "createdAt": createdAt.timeIntervalSince1970,
      "updatedAt": updatedAt.timeIntervalSince1970,
      "deviceId": deviceId,
      "isPinned": isPinned,
      "isLocalOnly": isLocalOnly
    ]

    if let sourceApp {
      payload["sourceApp"] = sourceApp
    }

    if let filtersHash {
      payload["filtersHash"] = filtersHash
    }

    if let cloudKitRecordID {
      payload["cloudKitRecordID"] = cloudKitRecordID
    }

    if let lastSyncError {
      payload["lastSyncError"] = lastSyncError
    }

    return try JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys])
  }
}
