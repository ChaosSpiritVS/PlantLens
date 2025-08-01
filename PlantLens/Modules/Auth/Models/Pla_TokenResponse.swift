//
//  Pla_TokenResponse.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/17.
//

import Foundation

struct Pla_TokenResponse: Decodable {
    let token: String
    let refresh_token: String
}
