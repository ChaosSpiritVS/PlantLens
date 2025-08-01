//
//  Pla_NetworkManager.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/17.
//

import Foundation
import Alamofire

final class Pla_NetworkManager: @unchecked Sendable {
    static let shared = Pla_NetworkManager()
    
    private let session: Session
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15

        let cookieHeader = ["Cookie": "XDEBUG_SESSION=PHPSTORM"]
        configuration.httpAdditionalHeaders = cookieHeader

        session = Session(configuration: configuration)
    }

    // MARK: - Async Await 通用请求接口
    func request<T: Decodable>(_ route: Pla_APIRouter, responseType: Pla_BaseResponse<T>.Type) async throws -> T {
        return try await executeRequest(route, responseType: responseType, retryOnAuthFail: true)
    }
    
    private func executeRequest<T: Decodable>(
        _ route: Pla_APIRouter,
        responseType: Pla_BaseResponse<T>.Type,
        retryOnAuthFail: Bool
    ) async throws -> T {
        let headers: HTTPHeaders? = {
            if route.requiresAuth, let token = Pla_UserSession.shared.token {
                return HTTPHeaders(["Authorization": "Bearer \(token)"])
            }
            return nil
        }()

        print("🌐 [Network Request Start]")
        print("🔗 URL: \(route.url)")
        print("📦 Method: \(route.method.rawValue)")
        print("🧾 Headers: \(headers?.dictionary ?? [:])")

        return try await withCheckedThrowingContinuation { continuation in
            let request: DataRequest
            
            if let multipart = route.multipartFormData {
                // 🌿 图片/文件上传
                request = session.upload(
                    multipartFormData: multipart,
                    to: route.url,
                    method: route.method,
                    headers: headers
                )
                print("📤 This request is a multipart upload (file/image).")

            } else {
                // 🌿 普通请求
                request = session.request(
                    route.url,
                    method: route.method,
                    parameters: route.parameters,
                    encoding: route.encoding,
                    headers: headers
                )
                print("📨 Parameters: \(route.parameters ?? [:])")
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            request
                .validate()
                .responseDecodable(of: Pla_BaseResponse<T>.self, decoder: decoder) { response in
                    print("📥 Status Code: \(response.response?.statusCode ?? -1)")
                    
                    if let data = response.data,
                       let jsonObject = try? JSONSerialization.jsonObject(with: data),
                       let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]) {
                        if let prettyString = String(data: prettyData, encoding: .utf8) {
                            print("📄 格式化 JSON 响应:\n\(prettyString)")
                        }
                    }
                    
                    switch response.result {
                    case .success(let baseResponse):
                        print("✅ Response Success: \(baseResponse.data)")
                        continuation.resume(returning: baseResponse.data)
                    case .failure(let error):
                        print("❌ Error: \(error)")
                        if let statusCode = response.response?.statusCode,
                           statusCode == 401, retryOnAuthFail {
                            Task {
                                do {
                                    _ = try await Pla_AuthService.refreshToken()
                                    let newValue = try await self.executeRequest(route, responseType: responseType, retryOnAuthFail: false)
                                    continuation.resume(returning: newValue)
                                } catch {
                                    Pla_AppCoordinator.shared.resetToRoot()
                                    Pla_UserSession.shared.clear()
                                    continuation.resume(throwing: NSError(domain: "Token refresh failed", code: 401))
                                }
                            }
                        } else {
                            continuation.resume(throwing: error)
                        }
                    }
                    print("🌐 [Network Request End]\n")
                }
        }
    }
}
