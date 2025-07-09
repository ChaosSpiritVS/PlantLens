//
//  UserDefaultsHelper.swift
//  Xync
//
//  Created by 李杰 on 2025/3/18.
//

import Foundation

class UserDefaultsHelper {
    // **单例模式**，整个项目中只使用 `UserDefaultsHelper.shared` 访问
    static let shared = UserDefaultsHelper()
    private let defaults = UserDefaults.standard

    // **防止外部创建新的实例**
    private init() {}

    // **Key 统一管理**
    private enum Keys {
        static let hasAcceptedPrivacyPolicy = "hasAcceptedPrivacyPolicy"
        static let currentUser = "currentUser"
        static let lastLoginDate = "lastLoginDate"
        static let appThemeMode = "appThemeMode"
        static let appleLanguages = "AppleLanguages"

    }

    // **是否同意用户协议**
    var hasAcceptedPrivacyPolicy: Bool {
        get { defaults.bool(forKey: Keys.hasAcceptedPrivacyPolicy) }
        set { defaults.set(newValue, forKey: Keys.hasAcceptedPrivacyPolicy) }
    }

    // **存储用户信息**
    var currentUser: Data? {
        get { defaults.data(forKey: Keys.currentUser) }
        set { defaults.set(newValue, forKey: Keys.currentUser) }
    }

    // **上次登录时间**
    var lastLoginDate: Date? {
        get { defaults.object(forKey: Keys.lastLoginDate) as? Date }
        set { defaults.set(newValue, forKey: Keys.lastLoginDate) }
    }

    // **App 主题模式 (0: 跟随系统, 1: 亮色, 2: 暗色)**
    var appThemeMode: Int {
        get { defaults.integer(forKey: Keys.appThemeMode) }
        set { defaults.set(newValue, forKey: Keys.appThemeMode)}
        
    }
    
    // **切换语言（需要重启 App 生效）**
    var switchLanguage: String? {
        get { defaults.string(forKey: Keys.appleLanguages) }
        set { defaults.set(newValue, forKey: Keys.appleLanguages); defaults.synchronize() }
    }

    // **清除所有存储数据（如用户退出登录时）**
    func clearUserData() {
        defaults.removeObject(forKey: Keys.currentUser)
        defaults.removeObject(forKey: Keys.lastLoginDate)
    }
}
