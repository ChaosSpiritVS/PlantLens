//
//  NavigationConfig.swift
//  Xync
//
//  Created by 李杰 on 2025/3/21.
//

import SwiftUI

struct NavigationConfig {
    static func setupGlobalNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        
        // ✅ 修改返回按钮图标颜色 & 彻底隐藏返回按钮文字
        UIBarButtonItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .highlighted)

        appearance.setBackIndicatorImage(
            UIImage(systemName: "chevron.left")?.withTintColor(.black, renderingMode: .alwaysOriginal),
            transitionMaskImage: UIImage(systemName: "chevron.left")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        )
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .black // 设置返回箭头颜色
        
        appearance.shadowColor = .clear // ✅ 隐藏底部分割线
    }
}
