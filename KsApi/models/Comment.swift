import Foundation

public struct Comment: Swift.Decodable {
  public let author: User
  public let body: String
  public let createdAt: TimeInterval
  public let deletedAt: TimeInterval?
  public let id: Int
}

extension Comment {
  enum CodingKeys: String, CodingKey {
    case author,
    body,
    createdAt = "created_at",
    deletedAt = "deleted_at",
    id
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.author = try values.decode(User.self, forKey: .author)
    self.body = try values.decode(String.self, forKey: .body)
    self.createdAt = try values.decode(TimeInterval.self, forKey: .createdAt)
    if let deleted = try? values.decode(TimeInterval.self, forKey: .deletedAt) {
      self.deletedAt = deleted > 0.0 ? deleted : nil
    } else {
      self.deletedAt = nil
    }
    self.id = try values.decode(Int.self, forKey: .id)
  }
}

extension Comment: Equatable {
}
public func == (lhs: Comment, rhs: Comment) -> Bool {
  return lhs.id == rhs.id
}

// Decode a time interval so that non-positive values are coalesced to `nil`. We do this because the API
// sends back `0` when the comment hasn't been deleted, and we'd rather handle that value as `nil`.
private func decodePositiveTimeInterval(_ interval: TimeInterval?) -> TimeInterval? {
  if let interval = interval, interval > 0.0 {
    return interval
  }
  return nil
}
