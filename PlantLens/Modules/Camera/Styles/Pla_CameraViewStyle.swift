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
    let tipEnsurePlant = CameraStrings.tipEnsurePlant
    let buttonImproveAccuracy = CameraStrings.improveAccuracy
    let buttonRecognize = CameraStrings.buttonRecognize
    let button360Recognize = CameraStrings.button360Recognize

    // MARK: - 图标
    let iconClose = Image(systemName: "xmark")
    let iconFlashOn = Image(systemName: "bolt.fill")
    let iconFlashOff = Image(systemName: "bolt.slash.fill")
    let iconFlipCamera = Image(systemName: "arrow.triangle.2.circlepath.camera")
    let iconHelp = Image(systemName: "questionmark.circle")
    let iconPhoto = Image(systemName: "photo")

    // MARK: - 颜色
    let backgroundColor = Color.black.opacity(0.8)
    let buttonColor = Color.white
    let accentColor = Color.green

    // MARK: - 尺寸
    let cornerRadius: CGFloat = 12.0
    let buttonSize: CGFloat = 60.0
}
