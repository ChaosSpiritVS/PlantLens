//
//  Pla_UserModel.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/4.
//

import Foundation

struct Pla_UserModel: Codable {
    var id: Int
    var name: String?
    var avatar: String?
    var phone: String
    var gender: String?
    var age: Int?
    var bio: String?
    var address: String?
}
