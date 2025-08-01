//
//  Pla_APIConfig.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/17.
//

import Foundation

enum APIEnvironment {
    case development
    case production

    var baseURL: String {
        switch self {
        case .development:
            return "http://192.168.51.214"
        case .production:
            return "https://api.amiav.xyz"
        }
    }
}

struct Pla_APIConfig {
    static let currentEnvironment: APIEnvironment = .development
    static var baseURL: String {
        return currentEnvironment.baseURL
    }
}
