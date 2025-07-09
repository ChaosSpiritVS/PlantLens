//
//  View+Extensions.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/9.
//

import SwiftUI

struct SettingsAlertViewModifier: ViewModifier {
    @ObservedObject private var permissionManager = Pla_PermissionManager.shared

    func body(content: Content) -> some View {
        content
            .alert(isPresented: $permissionManager.showSettingsAlert) {
                Alert(
                    title: Text("需要权限"),
                    message: Text("请在设置中启用对应权限以继续"),
                    primaryButton: .default(Text("去设置")) {
                        permissionManager.openSettings()
                    },
                    secondaryButton: .cancel()
                )
            }
    }
}

extension View {
    func withSettingsAlert() -> some View {
        self.modifier(SettingsAlertViewModifier())
    }
}
