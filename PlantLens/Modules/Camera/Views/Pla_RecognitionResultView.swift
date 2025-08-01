//
//  Pla_RecognitionResultView.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/14.
//

import SwiftUI

struct Pla_RecognitionResultView: View {
    let recognitionResult: Pla_RecognitionResult?

    var body: some View {
        VStack(spacing: 20) {
            Text("🌿 识别结果")
                .font(.largeTitle)
                .bold()

            if let result = recognitionResult, result != .placeholder {
                // ✅ 成功
                Text("植物名：\(result.name)")
                    .font(.title2)
                Text("拉丁名：\(result.scientificName)")
                    .foregroundColor(.secondary)
                Text("描述：\(result.description)")
                    .padding()
            } else {
                // ❌ 失败
                Text("😢 识别失败")
                    .font(.title2)
                    .foregroundColor(.red)
                Text("请检查网络或稍后再试")
                    .multilineTextAlignment(.center)
                    .padding()
            }

            Spacer()

            Button(action: {
                Pla_AppCoordinator.shared.dismiss(.plantDetail)
            }) {
                Label("返回首页", systemImage: "chevron.left")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
        .onAppear {
            Pla_AppCoordinator.shared.dismiss(.recognition)
        }
    }

}
