//
//  Pla_RecognitionResult.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/9.
//

import Foundation

/// 🌿 通用植物识别结果（GPT-4o / Gemini / 百度）
struct Pla_RecognitionResult: Identifiable, Codable {
    var id: String              // 本地唯一 ID 或 API 提供的 ID
    let name: String            // 植物中文名
    let latinName: String       // 拉丁学名
    let confidence: Double      // 置信度（0.0~1.0）
    let description: String     // 简短描述
    let imageUrl: URL?          // 示意图片

    enum CodingKeys: String, CodingKey {
        case id, name, latinName, confidence, description, imageUrl
    }

    // 自定义解码器：处理缺失字段、类型不一致
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // id: 优先 API 提供，否则生成 UUID
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "未知植物"
        latinName = try container.decodeIfPresent(String.self, forKey: .latinName) ?? "Unknown"
        confidence = try container.decodeIfPresent(Double.self, forKey: .confidence) ?? 0.0
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        
        // imageUrl: 支持字符串或直接 URL
        if let urlString = try container.decodeIfPresent(String.self, forKey: .imageUrl),
           let url = URL(string: urlString) {
            imageUrl = url
        } else {
            imageUrl = nil
        }
    }

    // 默认构造器
    init(id: String = UUID().uuidString,
         name: String,
         latinName: String,
         confidence: Double,
         description: String,
         imageUrl: URL? = nil) {
        self.id = id
        self.name = name
        self.latinName = latinName
        self.confidence = confidence
        self.description = description
        self.imageUrl = imageUrl
    }

    /// 🔖 占位结果
    static let placeholder = Pla_RecognitionResult(
        name: "未知植物",
        latinName: "Unknown",
        confidence: 0.0,
        description: "未能识别此植物，请重试。",
        imageUrl: nil
    )
}
