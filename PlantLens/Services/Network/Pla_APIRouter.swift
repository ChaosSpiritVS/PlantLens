//
//  Pla_APIRouter.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/17.
//

import Foundation
import Alamofire

/// 公共 API 协议
protocol Pla_APIRouter: Sendable {
    var module: String { get } // 📦 模块名（如 user、plants）
    var version: String { get } // 📌 API 版本
    var endpoint: String { get } // 📄 接口路径（模块内路径）
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var encoding: ParameterEncoding { get }
    var requiresAuth: Bool { get }
    var multipartFormData: MultipartFormData? { get }

    var url: String { get }
}

extension Pla_APIRouter {
    var baseURL: String { Pla_APIConfig.baseURL }

    /// 自动拼接完整 URL: baseURL + /api/v1/module/endpoint
    var url: String {
        "\(baseURL)/api/\(version)/\(module)/\(endpoint)"
    }

    /// 默认 POST 使用 JSON，GET 使用 URL 编码
    var encoding: ParameterEncoding {
        method == .get ? URLEncoding.default : JSONEncoding.default
    }
    
    var multipartFormData: MultipartFormData? { nil }
}
