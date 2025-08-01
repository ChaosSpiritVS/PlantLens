// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum CommonStrings {
  /// 诊断
  internal static let tabDiagnosis = CommonStrings.tr("Common", "tab_diagnosis", fallback: "诊断")
  /// 更多
  internal static let tabMore = CommonStrings.tr("Common", "tab_more", fallback: "更多")
  /// 植物
  internal static let tabPlant = CommonStrings.tr("Common", "tab_plant", fallback: "植物")
  /// Common.strings
  ///   PlantLens
  /// 
  ///   Created by 李杰 on 2025/7/8.
  internal static let tabRecommend = CommonStrings.tr("Common", "tab_recommend", fallback: "推荐")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension CommonStrings {
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
