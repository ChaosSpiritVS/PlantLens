//
//  Pla_Secrets.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/10.
//

import Foundation

enum Pla_Secrets {
    static let openAIKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String ?? ""
    static let geminiKey = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String ?? ""
    static let zenAI_GeminiKey = Bundle.main.object(forInfoDictionaryKey: "ZENAI_APP_KEY_GEMINI") as? String ?? ""
    static let zenAI_OpenAIKey = Bundle.main.object(forInfoDictionaryKey: "ZENAI_APP_KEY_OPENAI") as? String ?? ""
    static let baiduAPIKey = Bundle.main.object(forInfoDictionaryKey: "BAIDU_API_KEY") as? String ?? ""
    static let baiduSecretKey = Bundle.main.object(forInfoDictionaryKey: "BAIDU_SECRET_KEY") as? String ?? ""
}
