//
//  Pla_RecognitionResult.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/9.
//

import Foundation

/// 🌿 植物识别结果
struct Pla_RecognitionResult: Identifiable, Codable {
    var id = UUID()             // 本地唯一 ID
    let name: String            // 植物中文名
    let latinName: String       // 拉丁学名
    let confidence: Double      // 置信度（0.0~1.0）
    let description: String     // 简短描述
    let imageUrl: URL?          // GPT-4o 返回的示意图

    static let placeholder = Pla_RecognitionResult(
        name: "未知植物",
        latinName: "Unknown",
        confidence: 0,
        description: "未能识别此植物，请重试。",
        imageUrl: nil
    )
}
