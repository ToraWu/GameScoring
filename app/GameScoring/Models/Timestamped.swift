import Foundation

/// Every persisted entity carries an `updatedAt` for future sync conflict
/// resolution. Call `touch()` from every mutator so the timestamp stays current.
protocol Timestamped: AnyObject {
  var updatedAt: Date { get set }
}

extension Timestamped {
  func touch() {
    updatedAt = .now
  }
}
