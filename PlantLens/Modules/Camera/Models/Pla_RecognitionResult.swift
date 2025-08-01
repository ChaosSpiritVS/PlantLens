//
//  Pla_RecognitionResult.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/9.
//

import Foundation

/// 🌿 通用植物识别结果（GPT-4o  / 百度）
struct Pla_RecognitionResult: Identifiable, Codable, Equatable, Hashable {
    var id: Int                 // API 提供的 ID
    let name: String            // 植物中文名
    let scientificName: String       // 拉丁学名
    let confidence: String      // 置信度（0.0~1.0）
    let description: String     // 简短描述
    let coverImageUrl: URL?          // 示意图片
    
    // 新增字段（如果后端返回了这些信息就解析；否则为 nil）
    let symbolism: String?
    let historyLegends: String?
    let nameMeaning: String?
    let benefitsUses: String?
    let lifeCycles: String?
    let lifeTypes: [String]?
    let commonNames: [String]?
    let generaId: Int?
    
    /// 🔖 占位结果
    static let placeholder = Pla_RecognitionResult(
        id: 0,
        name: "未知植物",
        scientificName: "Unknown",
        confidence: "0.0",
        description: "未能识别此植物，请重试。",
        coverImageUrl: nil,
        symbolism: nil,
        historyLegends: nil,
        nameMeaning: nil,
        benefitsUses: nil,
        lifeCycles: nil,
        lifeTypes: nil,
        commonNames: nil,
        generaId: nil,
    )
}
