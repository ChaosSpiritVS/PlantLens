//
//  Pla_CameraRouter.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/17.
//

import Foundation
import Alamofire

enum Pla_CameraRouter: Pla_APIRouter {
    case recognize(imageData: Data)
}

extension Pla_CameraRouter {
    var module: String { "recognition" } // 📦 模块名
    var version: String { "v1" }  // 📌 API 版本

    var endpoint: String {
        switch self {
        case .recognize:
            return "upload"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .recognize:
            return .post
        }
    }

    var parameters: Parameters? {
        switch self {
        case .recognize:
            return nil
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .recognize:
            return false
        }
    }
    
    var multipartFormData: MultipartFormData? {
        switch self {
        case .recognize(let imageData):
            let timestamp = Int(Date().timeIntervalSince1970)
            let fileName = "plant_\(timestamp).jpg"
            let formData = MultipartFormData()
            formData.append(
                imageData,
                withName: "image", // ⚠️ 和后端字段名一致
                fileName: fileName,
                mimeType: "image/jpeg"
            )
            return formData
        }
    }
    
}
