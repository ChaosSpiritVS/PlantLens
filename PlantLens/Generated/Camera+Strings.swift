// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum CameraStrings {
  /// 360°识别
  internal static let button360Recognize = CameraStrings.tr("Camera", "button_360_recognize", fallback: "360°识别")
  /// 识别
  internal static let buttonRecognize = CameraStrings.tr("Camera", "button_recognize", fallback: "识别")
  /// 提高准确性
  internal static let improveAccuracy = CameraStrings.tr("Camera", "improve_accuracy", fallback: "提高准确性")
  /// Camera.strings
  ///   PlantLens
  /// 
  ///   Created by 李杰 on 2025/7/4.
  internal static let tipEnsurePlant = CameraStrings.tr("Camera", "tip_ensure_plant", fallback: "确保植物在镜头中清晰可见")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension CameraStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
