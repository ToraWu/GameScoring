import Foundation

/// App version info read from the bundle (never hardcoded). The release version
/// is `CFBundleShortVersionString` (MARKETING_VERSION); the dev build is
/// `CFBundleVersion` (CURRENT_PROJECT_VERSION, bumped each commit).
enum AppVersion {
  static var release: String {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
  }

  static var build: String {
    Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
  }

  /// e.g. "BoardScore 1.0.1 · build 4"
  static var footer: String {
    "BoardScore \(release) · build \(build)"
  }
}
