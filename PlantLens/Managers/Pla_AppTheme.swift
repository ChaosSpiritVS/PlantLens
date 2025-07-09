//
//  AppTheme.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/8.
//

import SwiftUI

enum AppTheme {
    
    // MARK: - Colors
    struct Colors {
        static let primary = CommonAssets.primary // #4CAF50
        static let secondary = CommonAssets.secondary // #81C784
        static let accent = CommonAssets.accent // #FFB74D
        static let error = CommonAssets.error // #E57373
        static let background = CommonAssets.background // #F1F8E9
        static let cardBackground = CommonAssets.cardBackground // #FFFFFF
        static let textPrimary = CommonAssets.textPrimary // #212121
        static let textSecondary = CommonAssets.textSecondary // #757575
        static let textDisabled = CommonAssets.textDisabled // #BDBDBD
        
    }

    // MARK: - Fonts
    struct Fonts {
        static func title(size: CGFloat = 24) -> Font {
            .system(size: size, weight: .semibold, design: .rounded)
        }

        static func body(size: CGFloat = 16) -> Font {
            .system(size: size, weight: .regular, design: .default)
        }

        static func caption(size: CGFloat = 12) -> Font {
            .system(size: size, weight: .regular, design: .monospaced)
        }

        static func button(size: CGFloat = 18) -> Font {
            .system(size: size, weight: .medium, design: .rounded)
        }
    }

    // MARK: - Icons (SFSymbols)
    struct Icons {
        static let flashOn = Image(systemName: "bolt.fill")
        static let flashOff = Image(systemName: "bolt.slash.fill")
        static let flipCamera = Image(systemName: "arrow.triangle.2.circlepath.camera")
        static let help = Image(systemName: "questionmark.circle")
        static let close = Image(systemName: "xmark.circle.fill")
    }

    // MARK: - Shadows
    struct Shadows {
        static let card = Color.black.opacity(0.1)
        static let button = Color.black.opacity(0.15)
    }
}
