//
//  ContentView.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/2.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject var coordinator = Pla_AppCoordinator.shared

    var body: some View {
        Group {
            Pla_MainTabView()
        }
        .environmentObject(coordinator)

        // ✅ 堆叠所有 fullScreenCover
        .fullScreenCover(isPresented: Binding(
            get: { coordinator.modalStack.contains(where: { $0.1 == .fullScreen }) },
            set: { isPresented in
                if !isPresented {
                    coordinator.dismiss(type: .fullScreen)
                }
            }
        )) {
            ZStack {
                ForEach(Array(coordinator.modalStack.enumerated()), id: \.offset) { index, modal in
                    if modal.1 == .fullScreen {
                        modal.0.view()
                            .zIndex(Double(index))
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        }

        // ✅ 单独处理最顶层 sheet（一次只显示一个）
        .sheet(item: Binding<Pla_Screen?>(
            get: {
                coordinator.modalStack.last(where: { $0.1 == .sheet })?.0
            },
            set: { _, _ in
                coordinator.dismiss(type: .sheet)
            }
        )) { screen in
            screen.view()
        }
    }
}

#Preview {
    ContentView()
//        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
