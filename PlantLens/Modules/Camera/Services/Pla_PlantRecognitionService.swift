//
//  Pla_PlantRecognitionService.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/9.
//

import Foundation
import UIKit

/// 🌱 植物识别服务（GPT-4o + Gemini 2.5 + 百度实现）
class Pla_PlantRecognitionService {
    static let shared = Pla_PlantRecognitionService()

    private let openAIAPIKey = Pla_Secrets.zenAI_OpenAIKey
    private let endpoint = "https://zen-ai.top/v1/chat/completions"
    //"https://api.openai.com/v1/chat/completions"
    
    private let geminiAPIKey = Pla_Secrets.zenAI_GeminiKey
    private let geminiEndpoint = "https://zen-ai.top/v1/models/gemini-2.5-flash:generateContent?key="
    //"https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key="

    private let baiduAPIKey = Pla_Secrets.baiduAPIKey
    private let baiduSecretKey = Pla_Secrets.baiduSecretKey
    private var baiduAccessToken: String?

    private init() {}

    /// 🔍 主入口：GPT-4o → Gemini 2.5 → 百度
    func identifyPlant(image: UIImage, completion: @escaping (Result<Pla_RecognitionResult, Error>) -> Void) {
        identifyWithGPT4o(image: image) { result in
            switch result {
            case .success(let res):
                completion(.success(res))
            case .failure(let err):
                completion(.failure(err))
            }
        }
        
//        identifyWithGemini(image: image) { result in
//            switch result {
//            case .success(let res):
//                completion(.success(res))
//            case .failure(let err):
//                completion(.failure(err))
//            }
//        }
        
//        identifyWithBaidu(image: image) { result in
//            switch result {
//            case .success(let res):
//                completion(.success(res))
//            case .failure(let err):
//                completion(.failure(err))
//            }
//        }
        
    }

    /// 🌿 使用 GPT-4o 识别植物
    private func identifyWithGPT4o(image: UIImage, completion: @escaping (Result<Pla_RecognitionResult, Error>) -> Void) {
        // ≤1MB，最长边2048
        guard let imageData = resizeImageForModel(
            image,
            maxBase64SizeKB: 1024, // 1MB
            maxLength: 2048,
            startCompression: 0.8
        ) else {
            completion(.failure(NSError(domain: "ImageConversionError", code: -1)))
            return
        }

        let base64Image = imageData.base64EncodedString()

        let messages: [[String: Any]] = [
            [
                "role": "system",
                "content": "你是一个植物识别专家，请根据用户上传的植物图片，返回植物的中文名、拉丁名、置信度（0-1）、简短描述和示意图片URL（如果有）。结果格式为JSON：{\"name\":\"\",\"latinName\":\"\",\"confidence\":0.9,\"description\":\"\",\"imageUrl\":\"\"}"
            ],
            [
                "role": "user",
                "content": [
                    [
                        "type": "image_url",
                        "image_url": [
                            "url": "data:image/jpeg;base64,\(base64Image)"
                        ]
                    ]
                ]
            ]
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
            print("❌ JSON序列化错误：\(error)")
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ GPT-4o 请求错误：\(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("❌ GPT-4o 返回数据为空")
                completion(.failure(NSError(domain: "NoDataError", code: -1)))
                return
            }

            // 📝 打印返回的完整 JSON
            if let rawJson = try? JSONSerialization.jsonObject(with: data, options: []),
               let prettyData = try? JSONSerialization.data(withJSONObject: rawJson, options: [.prettyPrinted, .withoutEscapingSlashes]),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                print("🟢 GPT-4o 返回的完整 JSON：\n\(prettyString)")
            } else {
                print("⚠️ 无法格式化 GPT-4o 返回的数据")
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let content = choices.first?["message"] as? [String: Any],
                   let resultText = content["content"] as? String {
                    
                    guard let cleanedJSON = self.extractJSON(from: resultText) else {
                        print("❌ 无法从文本中提取有效 JSON")
                        completion(.failure(NSError(domain: "JSONExtractError", code: -11)))
                        return
                    }
                    
                    if let resultData = cleanedJSON.data(using: .utf8) {
                        let result = try JSONDecoder().decode(Pla_RecognitionResult.self, from: resultData)
                        completion(.success(result))
                    } else {
                        print("❌ 无法将提取后的字符串转为 Data")
                        completion(.failure(NSError(domain: "DataConversionError", code: -10)))
                    }
                    
                } else {
                    print("❌ GPT-4o JSON解析失败，缺少关键字段")
                    completion(.failure(NSError(domain: "ParseError", code: -1)))
                }
            } catch {
                print("❌ GPT-4o JSON反序列化错误：\(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    // 🌿 使用 Gemini 2.5 识别植物
    private func identifyWithGemini(image: UIImage, completion: @escaping (Result<Pla_RecognitionResult, Error>) -> Void) {
        // ≤2MB，最长边2048
        guard let imageData = resizeImageForModel(
            image,
            maxBase64SizeKB: 2048, // 2MB
            maxLength: 2048,
            startCompression: 0.8
        ) else {
            completion(.failure(NSError(domain: "ImageConversionError", code: -1)))
            return
        }
        
        let base64Image = imageData.base64EncodedString()

        let payload: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": """
                            你是一个植物识别专家，请根据用户上传的植物图片，返回植物的中文名、拉丁名、置信度（0-1）、简短描述和示意图片URL（如果有）。
                            结果格式为JSON：{"name":"","latinName":"","confidence":0.9,"description":"","imageUrl":""}
                        """],
                        ["inline_data": [
                            "mime_type": "image/jpeg",
                            "data": base64Image
                        ]]
                    ]
                ]
            ]
        ]

        guard let url = URL(string: geminiEndpoint + geminiAPIKey) else {
            completion(.failure(NSError(domain: "InvalidURL", code: -2)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            print("❌ Gemini JSON序列化错误：\(error)")
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("❌ Gemini 请求错误：\(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let data = data else {
                print("❌ Gemini 返回数据为空")
                completion(.failure(NSError(domain: "NoDataError", code: -1)))
                return
            }

            // 📝 打印返回的完整 JSON
            if let rawJson = try? JSONSerialization.jsonObject(with: data, options: []),
               let prettyData = try? JSONSerialization.data(withJSONObject: rawJson, options: [.prettyPrinted, .withoutEscapingSlashes]),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                print("🟢 Gemini 2.5 返回的完整 JSON：\n\(prettyString)")
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let candidates = json["candidates"] as? [[String: Any]],
                   let content = candidates.first?["content"] as? [String: Any],
                   let parts = content["parts"] as? [[String: Any]],
                   let rawText = parts.first?["text"] as? String {
                    
                    guard let cleanedJSON = self.extractJSON(from: rawText) else {
                        print("❌ 无法从文本中提取有效 JSON")
                        completion(.failure(NSError(domain: "JSONExtractError", code: -11)))
                        return
                    }

                    if let resultData = cleanedJSON.data(using: .utf8) {
                        let result = try JSONDecoder().decode(Pla_RecognitionResult.self, from: resultData)
                        completion(.success(result))
                    } else {
                        print("❌ 无法将提取后的字符串转为 Data")
                        completion(.failure(NSError(domain: "DataConversionError", code: -10)))
                    }

                } else {
                    print("❌ Gemini JSON解析失败，缺少关键字段")
                    completion(.failure(NSError(domain: "ParseError", code: -1)))
                }
            } catch {
                print("❌ Gemini JSON反序列化错误：\(error)")
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
        // ≤4MB，最长边4096
        guard let finalImageData = resizeImageForModel(
            image,
            maxBase64SizeKB: 4096, // 4MB
            maxLength: 4096,
            startCompression: 0.7
        ) else {
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
                    let prettyData = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .withoutEscapingSlashes])
                    if let prettyString = String(data: prettyData, encoding: .utf8) {
                        print("🟢 百度API 返回的完整 JSON：\n\(prettyString)")
                    } else {
                        print("🟢 百度API 返回的完整 JSON（编码失败）")
                    }

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
    
    /// 🛡️ 从文本中提取有效 JSON
    private func extractJSON(from text: String) -> String? {
        var cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // 1️⃣ 去掉 ```json 或 ```
        if cleaned.hasPrefix("```json") {
            cleaned = String(cleaned.dropFirst(6))
        }
        if cleaned.hasPrefix("```") {
            cleaned = String(cleaned.dropFirst(3))
        }
        if cleaned.hasSuffix("```") {
            cleaned = String(cleaned.dropLast(3))
        }
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)

        // 2️⃣ 尝试从文本中提取第一个 {…}
        if let start = cleaned.firstIndex(of: "{"),
           let end = cleaned.lastIndex(of: "}") {
            let jsonSubstring = cleaned[start...end]
            return String(jsonSubstring)
        }

        return nil
    }
    
    /// 🌿 通用图片压缩方法
    private func resizeImageForModel(
        _ image: UIImage,
        maxBase64SizeKB: Int = 4096,          // 默认 4MB（百度）
        maxLength: CGFloat = 4096,            // 默认最长边 4096（百度）
        minLength: CGFloat = 15,              // 默认最短边 15
        startCompression: CGFloat = 0.8,      // 起始压缩质量
        minCompression: CGFloat = 0.2,        // 最低压缩质量
        maxAttempts: Int = 6                  // 最大尝试次数
    ) -> Data? {
        var targetImage = image
        var compression = startCompression

        for attempt in 1...maxAttempts {
            // 1️⃣ 缩放尺寸
            if let resized = resizeImage(targetImage, maxLength: maxLength, minLength: minLength) {
                targetImage = resized
            }

            // 2️⃣ 压缩 JPEG
            guard let jpegData = targetImage.jpegData(compressionQuality: compression) else { return nil }

            // 3️⃣ 计算 Base64 大小（≈ jpegData.count * 4 / 3）
            let base64SizeKB = Int(Double(jpegData.count) * 4.0 / 3.0 / 1024.0)
            print("📦 尝试 #\(attempt)：Base64 大小 \(base64SizeKB)KB (质量: \(compression))")

            if base64SizeKB <= maxBase64SizeKB {
                print("✅ 图片已优化 (≤ \(maxBase64SizeKB)KB)")
                return jpegData
            }

            // 4️⃣ 不够小 → 降低质量
            compression -= 0.1
            if compression < minCompression {
                print("⚠️ 压缩质量已到最低 (\(minCompression))，仍大于 \(maxBase64SizeKB)KB")
                break
            }
        }

        print("❌ 无法将图片压缩至 \(maxBase64SizeKB)KB 内")
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
