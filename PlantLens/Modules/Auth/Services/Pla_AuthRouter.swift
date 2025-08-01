//
//  Pla_AuthRouter.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/17.
//

import Foundation
import Alamofire

enum Pla_AuthRouter: Pla_APIRouter {
    case verificationCodeLogin(phone: String, code: String)
    case oneClickLogin(phone: String, token: String)
    case sendVerificationCode(phone: String)
    case refreshToken(refreshToken: String)
    case logout
}

extension Pla_AuthRouter {
    var module: String { "auth" } // 📦 模块名
    var version: String { "v1" }  // 📌 API 版本

    var endpoint: String {
        switch self {
        case .verificationCodeLogin:
            return "verificationCodeLogin"
        case .oneClickLogin:
            return "oneClickLogin"
        case .sendVerificationCode:
            return "sendVerificationCode"
        case .refreshToken:
            return "refreshToken"
        case .logout:
            return "logout"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .verificationCodeLogin: return .post
        case .oneClickLogin: return .post
        case .sendVerificationCode: return .post
        case .refreshToken: return .post
        case .logout: return .post
        }
    }

    var parameters: Parameters? {
        switch self {
        case .verificationCodeLogin(let phone, let code):
            return ["phone": phone, "code": code]
        case .oneClickLogin(let phone, let token):
            return ["phone": phone, "token": token]
        case .sendVerificationCode(let phone):
            return ["phone": phone]
        case .refreshToken(let refreshToken):
            return ["refresh_token": refreshToken]
        default: return nil
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .verificationCodeLogin: return false
        case .oneClickLogin: return false
        case .sendVerificationCode: return false
        case .refreshToken: return false
        default: return true
        }
    }
    
}
