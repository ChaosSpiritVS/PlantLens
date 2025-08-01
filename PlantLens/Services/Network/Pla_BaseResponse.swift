//
//  Pla_BaseResponse.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/24.
//

import Foundation

struct Pla_BaseResponse<T: Codable>: Codable {
    let success: Bool
    let data: T
}
