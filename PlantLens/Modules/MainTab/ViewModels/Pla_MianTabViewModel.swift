//
//  Pla_MianTabViewModel.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/8.
//

import SwiftUI

class Pla_MianTabViewModel: ObservableObject {
    @Published var style = Pla_MainTabViewStyle()
    
    // 模态相机界面
    func presentCameraView() {
        Pla_AppCoordinator.shared.present(.camera)
    }
    
}
