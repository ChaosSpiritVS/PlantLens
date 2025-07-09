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
    static let tipEnsurePlant = CameraStrings.tipEnsurePlant
    static let buttonImproveAccuracy = CameraStrings.improveAccuracy
    static let buttonRecognize = CameraStrings.buttonRecognize
    static let button360Recognize = CameraStrings.button360Recognize

    // MARK: - 图标
    static let iconClose = Image(systemName: "xmark")
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
