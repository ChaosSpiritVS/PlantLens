//
//  Pla_RecognitionResponse.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/31.
//

import Foundation

struct Pla_RecognitionResponse: Codable {
    let flower: Pla_RecognitionResult
    let imageId: Int
}
