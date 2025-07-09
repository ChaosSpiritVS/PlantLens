//
//  Pla_MianTabView.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/3.
//

import SwiftUI

struct Pla_MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var viewModel = Pla_MianTabViewModel()

    var body: some View {
        ZStack {
            // MARK: - TabView
            TabView(selection: $selectedTab) {
                // 推荐 Tab
                Pla_RecommendView()
                    .tabItem {
                        viewModel.style.recommend.iconNormal
                        Text(viewModel.style.recommend.title)
                    }
                    .tag(0)

                // 诊断 Tab
                Pla_DiagnosisView()
                    .tabItem {
                        viewModel.style.diagnosis.iconNormal
                        Text(viewModel.style.diagnosis.title)
                    }
                    .tag(1)

                // 中间相机 Tab (占位)
                Color.clear
                    .tabItem {
                        Image(systemName: "")
                        Text("")
                    }
                    .tag(2)

                // 植物 Tab
                Pla_PlantsView()
                    .tabItem {
                        viewModel.style.plant.iconNormal
                        Text(viewModel.style.plant.title)
                    }
                    .tag(3)

                // 更多 Tab
                Pla_MoreView()
                    .tabItem {
                        viewModel.style.more.iconNormal
                        Text(viewModel.style.more.title)
                    }
                    .tag(4)
            }
            .onChange(of: selectedTab) { newValue in
                if newValue == 2 {
                    Pla_PermissionManager.shared.check(.camera) {
                        print("已获得相机权限，继续打开相机")
                        viewModel.presentCameraView()
                    }
                    selectedTab = 0 // 自动切回推荐 Tab，防止切换页面
                }
            }
            .withSettingsAlert()

            // MARK: - 突出的相机按钮
            VStack {
                Spacer()
                HStack {
                    Spacer()

                    Button(action: {
                        Pla_PermissionManager.shared.check(.camera) {
                            print("已获得相机权限，继续打开相机")
                            viewModel.presentCameraView()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .foregroundColor(.green)
                                .frame(width: 64, height: 64)
                                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)

                            Image(systemName: "camera.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 28))
                        }
                    }
                    .offset(y: -10) // 让按钮在 TabBar 上方突出
                    .withSettingsAlert()


                    Spacer()
                }
            }
        }
    }
}

#Preview {
    Pla_MainTabView()
}
