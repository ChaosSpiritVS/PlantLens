//
//  Pla_AuthService.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/17.
//

import Foundation
import Alamofire

final class Pla_AuthService {
    static func refreshToken() async throws -> String {
        let refreshToken = Pla_UserSession.shared.refreshToken

        guard let refreshToken else {
            throw NSError(domain: "No refresh token", code: 401)
        }
        
        let route = Pla_AuthRouter.refreshToken(refreshToken: refreshToken)
        let response = try await AF.request(route.url, method: route.method, parameters: route.parameters, encoding: route.encoding)
                    .validate()
                    .serializingDecodable(Pla_TokenResponse.self).value
        // 保存新 token
        Pla_UserSession.shared.token = response.token
        Pla_UserSession.shared.refreshToken = response.refresh_token

        return response.token
    }
}
