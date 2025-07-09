//
//  Pla_PlantRecognitionService.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/9.
//

import Foundation
import UIKit

/// 🌱 植物识别服务（GPT-4o + 百度实现）
class Pla_PlantRecognitionService {
    static let shared = Pla_PlantRecognitionService()

    private let openAIAPIKey = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String ?? ""
    private let endpoint = "https://api.openai.com/v1/chat/completions"

    private let baiduAPIKey = Bundle.main.infoDictionary?["BAIDU_API_KEY"] as? String ?? ""
    private let baiduSecretKey = Bundle.main.infoDictionary?["BAIDU_SECRET_KEY"] as? String ?? ""
    private var baiduAccessToken: String?

    private init() {}

    /// 🔍 主入口：优先 GPT-4o，失败时自动降级百度
    func identifyPlant(image: UIImage, completion: @escaping (Result<Pla_RecognitionResult, Error>) -> Void) {
        identifyWithGPT4o(image: image) { result in
            switch result {
            case .success(let res):
                completion(.success(res))
            case .failure:
                print("⚠️ GPT-4o 识别失败，尝试使用百度API")
                self.identifyWithBaidu(image: image, completion: completion)
            }
        }
    }

    /// 🌿 使用 GPT-4o 识别植物
    private func identifyWithGPT4o(image: UIImage, completion: @escaping (Result<Pla_RecognitionResult, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(.failure(NSError(domain: "ImageConversionError", code: -1)))
            return
        }

        let base64Image = imageData.base64EncodedString()

        let messages: [[String: String]] = [
            ["role": "system", "content": "你是一个植物识别专家，请根据用户上传的植物图片，返回植物的中文名、拉丁名、置信度（0-1）、简短描述和示意图片URL（如果有）。结果格式为JSON：{\"name\":\"\",\"latinName\":\"\",\"confidence\":0.9,\"description\":\"\",\"imageUrl\":\"\"}"],
            ["role": "user", "content": "图片数据：data:image/jpeg;base64,\(base64Image)"]
        ]

        let payload: [String: Any] = [
            "model": "gpt-4o",
            "messages": messages,
            "max_tokens": 500,
            "temperature": 0.2
        ]

        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "NoDataError", code: -1)))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let content = choices.first?["message"] as? [String: Any],
                   let resultText = content["content"] as? String,
                   let resultData = resultText.data(using: .utf8) {
                    let result = try JSONDecoder().decode(Pla_RecognitionResult.self, from: resultData)
                    completion(.success(result))
                } else {
                    completion(.failure(NSError(domain: "ParseError", code: -1)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    /// 🌿 使用百度植物识别
    private func identifyWithBaidu(image: UIImage, completion: @escaping (Result<Pla_RecognitionResult, Error>) -> Void) {
        getBaiduAccessToken { tokenResult in
            switch tokenResult {
            case .failure(let err):
                completion(.failure(err))
            case .success(let token):
                self.callBaiduPlantAPI(image: image, token: token, completion: completion)
            }
        }
    }

    /// 🔑 获取百度AccessToken（如果已缓存则直接用）
    private func getBaiduAccessToken(completion: @escaping (Result<String, Error>) -> Void) {
        if let token = baiduAccessToken {
            completion(.success(token))
            return
        }
        let urlStr = "https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=\(baiduAPIKey)&client_secret=\(baiduSecretKey)"
        guard let url = URL(string: urlStr) else {
            completion(.failure(NSError(domain: "InvalidURL", code: -2)))
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let token = json["access_token"] as? String else {
                completion(.failure(NSError(domain: "BaiduTokenError", code: -3)))
                return
            }
            self.baiduAccessToken = token
            completion(.success(token))
        }.resume()
    }

    /// 🌿 调用百度植物识别API
    private func callBaiduPlantAPI(image: UIImage, token: String, completion: @escaping (Result<Pla_RecognitionResult, Error>) -> Void) {
        // 1️⃣ 压缩并调整尺寸
        guard let finalImageData = resizeImageToFitBaidu(image) else {
            completion(.failure(NSError(domain: "ImageTooLargeError", code: -7)))
            return
        }

        // 2️⃣ Base64 编码（去头、去换行）
        var base64Image = finalImageData.base64EncodedString()
        base64Image = base64Image.replacingOccurrences(of: "\n", with: "")
        base64Image = base64Image.replacingOccurrences(of: "\r", with: "")
        if base64Image.hasPrefix("data:image") {
            if let range = base64Image.range(of: "base64,") {
                base64Image = String(base64Image[range.upperBound...])
            }
        }

        // 3️⃣ URL Encode
        guard let encodedBase64 = base64Image.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else {
            completion(.failure(NSError(domain: "URLEncodeError", code: -8)))
            return
        }

        // 4️⃣ 组装请求体
        let body = "image=\(encodedBase64)&baike_num=1"
        
        guard let url = URL(string: "https://aip.baidubce.com/rest/2.0/image-classify/v1/plant?access_token=\(token)") else {
            completion(.failure(NSError(domain: "InvalidURL", code: -5)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data else {
                print("❌ 返回数据为空")
                completion(.failure(NSError(domain: "BaiduParseError", code: -6)))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("🟢 返回的完整 JSON：\(json)")

                    guard let results = json["result"] as? [[String: Any]],
                          let first = results.first,
                          let name = first["name"] as? String,
                          let score = first["score"] as? Double else {
                        print("❌ 解析JSON失败，缺少必要字段")
                        completion(.failure(NSError(domain: "BaiduParseError", code: -6)))
                        return
                    }
                    
                    let baike = first["baike_info"] as? [String: Any]
                    let description = baike?["description"] as? String ?? ""
                    let imageUrl = baike?["image_url"] as? String ?? ""

                    let result = Pla_RecognitionResult(
                        name: name,
                        latinName: "",
                        confidence: score,
                        description: description,
                        imageUrl: URL(string: imageUrl)
                    )
                    completion(.success(result))
                    
                } else {
                    print("❌ JSON格式不正确")
                    completion(.failure(NSError(domain: "BaiduParseError", code: -6)))
                }
            } catch {
                print("❌ JSON反序列化错误：\(error)")
                completion(.failure(error))
            }
                        
        }.resume()
    }
    
    private func resizeImageToFitBaidu(_ image: UIImage) -> Data? {
        var targetImage = image
        var compression: CGFloat = 0.7

        // 循环调整：先缩放尺寸，再降压缩质量
        for _ in 0..<5 {
            // 1️⃣ 缩放尺寸
            if let resized = resizeImage(targetImage, maxLength: 4096, minLength: 15) {
                targetImage = resized
            }

            // 2️⃣ 压缩 JPEG
            guard let jpegData = targetImage.jpegData(compressionQuality: compression) else { return nil }
            
            // 🆕 打印 JPEG 文件头（前10字节）
            let headerBytes = jpegData.prefix(10).map { String(format: "%02X", $0) }.joined(separator: " ")
            print("📸 JPEG 文件头：\(headerBytes)")

            // 3️⃣ 计算 Base64 大小（实际 = jpegData.count * 4 / 3）
            let base64Size = Int(Double(jpegData.count) * 4.0 / 3.0)
            print("📦 压缩后 Base64 预计大小：\(base64Size / 1024) KB (质量: \(compression))")

            if base64Size <= 4 * 1024 * 1024 {
                // ✅ 符合要求
                return jpegData
            }

            // 4️⃣ 不够小 → 降低质量再试
            compression -= 0.1
            if compression < 0.1 {
                print("⚠️ 压缩质量已到最低，仍大于4MB")
                break
            }
        }

        print("❌ 无法将图片压缩至 4MB 内")
        return nil
    }
    
    private func resizeImage(_ image: UIImage, maxLength: CGFloat = 4096, minLength: CGFloat = 15) -> UIImage? {
        let size = image.size
        let width = size.width
        let height = size.height
        
        // 找最长边和最短边
        _ = max(width, height)
        let minSide = min(width, height)
        
        // 如果最短边小于15，按比例放大到最短边15
        var targetWidth = width
        var targetHeight = height
        if minSide < minLength {
            let scale = minLength / minSide
            targetWidth = width * scale
            targetHeight = height * scale
        }
        
        // 如果最长边大于4096，按比例缩小到最长边4096
        if max(targetWidth, targetHeight) > maxLength {
            let scale = maxLength / max(targetWidth, targetHeight)
            targetWidth *= scale
            targetHeight *= scale
        }
        
        let targetSize = CGSize(width: targetWidth, height: targetHeight)
        
        // UIGraphicsImageRenderer绘制新的UIImage
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let newImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return newImage
    }
}
