//
//  Pla_CameraViewStrings.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/4.
//

import Foundation
import SwiftUICore

struct Pla_CameraViewStyle {
    // MARK: - 文本
    static let tipEnsurePlant = NSLocalizedString("camera_tip_ensure_plant", comment: "确保植物在镜头中清晰可见")
    static let buttonImproveAccuracy = NSLocalizedString("camera_improve_accuracy", comment: "提高准确性")
    static let buttonTakePhoto = NSLocalizedString("camera_take_photo", comment: "拍照")

    // MARK: - 图标
    static let iconFlashOn = Image(systemName: "bolt.fill")
    static let iconFlashOff = Image(systemName: "bolt.slash.fill")
    static let iconFlipCamera = Image(systemName: "arrow.triangle.2.circlepath.camera")
    static let iconHelp = Image(systemName: "questionmark.circle")

    // MARK: - 颜色
    static let backgroundColor = Color.black.opacity(0.8)
    static let buttonColor = Color.white
    static let accentColor = Color.green

    // MARK: - 尺寸
    static let cornerRadius: CGFloat = 12.0
    static let buttonSize: CGFloat = 60.0
}
