//
//  Pla_MianTabViewStyle.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/8.
//

import Foundation
import SwiftUI

struct Pla_MainTabViewStyle {
    
    struct TabItem {
        let iconNormal: Image
        let iconSelected: Image
        let title: String
        let normalColor: Color
        let selectedColor: Color
    }
    
    // MARK: - 推荐 Tab
    let recommend = TabItem(
        iconNormal: Image(systemName: "star"),
        iconSelected: Image(systemName: "star.fill"),
        title: CommonStrings.tabRecommend,
        normalColor: Color.gray,
        selectedColor: Color.blue
    )
    
    // MARK: - 诊断 Tab
    let diagnosis = TabItem(
        iconNormal: Image(systemName: "stethoscope"),
        iconSelected: Image(systemName: "stethoscope.circle.fill"), // 填充图标
        title: CommonStrings.tabDiagnosis,
        normalColor: Color.gray,
        selectedColor: Color.pink
    )
    
    // MARK: - 植物 Tab
    let plant = TabItem(
        iconNormal: Image(systemName: "leaf"),
        iconSelected: Image(systemName: "leaf.fill"),
        title: CommonStrings.tabPlant,
        normalColor: Color.gray,
        selectedColor: Color.green
    )
    
    // MARK: - 更多 Tab
    let more = TabItem(
        iconNormal: Image(systemName: "ellipsis.circle"),
        iconSelected: Image(systemName: "ellipsis.circle.fill"), // 填充图标
        title: CommonStrings.tabMore,
        normalColor: Color.gray,
        selectedColor: Color.orange
    )
    
}
