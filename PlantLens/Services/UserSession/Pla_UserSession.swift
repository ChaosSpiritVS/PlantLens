//
//  Pla_UserSession.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/3.
//

import Foundation

final class Pla_UserSession: ObservableObject {
    static let shared = Pla_UserSession()

    private let tokenKey = "auth_token"
    private let refreshTokenKey = "auth_refresh_token"

    // 将 token 转化为存储属性，并加上 @Published
    @Published private var _token: String? {
        didSet {
            // 这里可以同步更新 token 到 Keychain 或其他地方
            if let newToken = _token {
                KeychainHelper.shared.save(newToken, forKey: tokenKey)
            } else {
                KeychainHelper.shared.delete(tokenKey)
            }
        }
    }
    
    var token: String? {
        get { _token }
        set { _token = newValue }
    }
    
    var refreshToken: String? {
        get { KeychainHelper.shared.read(refreshTokenKey) }
        set {
            if let newValue = newValue {
                KeychainHelper.shared.save(newValue, forKey: refreshTokenKey)
            } else {
                KeychainHelper.shared.delete(refreshTokenKey)
            }
        }
    }

    var currentUser: Pla_UserModel? {
        get {
            guard let data = UserDefaultsHelper.shared.currentUser else { return nil }
            return try? JSONDecoder().decode(Pla_UserModel.self, from: data)
        }
        set {
            if let user = newValue,
               let data = try? JSONEncoder().encode(user) {
                UserDefaultsHelper.shared.currentUser = data
            } else {
                UserDefaultsHelper.shared.clearUserData()
            }
        }
    }

    var isLoggedIn: Bool {
        return token != nil
    }

    func clear() {
        token = nil
        refreshToken = nil
        currentUser = nil
    }

    private init() {
        // 初始化时尝试从 Keychain 获取 token
        _token = KeychainHelper.shared.read(tokenKey)
    }
}
