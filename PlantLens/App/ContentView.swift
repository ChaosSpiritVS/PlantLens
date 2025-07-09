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
//    @StateObject var session = Pla_UserSession.shared

    var body: some View {
        Group {
            Pla_MainTabView()
        }
        .environmentObject(coordinator) // ✅ 传递给所有子视图
        
        // 👇 这里的 Binding 只在 modalScreen.type == .fullScreen 时生效
        .fullScreenCover(item: Binding<Pla_Screen?>(
            get: {
                guard coordinator.modalScreen?.1 == .fullScreen else { return nil }
                return coordinator.modalScreen?.0
            },
            set: { _, _ in coordinator.dismiss() }
        )) { screen in
            screen.view()
        }
        
        // 👇 这里的 Binding 只在 modalScreen.type == .sheet 时生效
        .sheet(item: Binding<Pla_Screen?>(
            get: {
                guard coordinator.modalScreen?.1 == .sheet else { return nil }
                return coordinator.modalScreen?.0
            },
            set: { _, _ in coordinator.dismiss() }
        )) { screen in
            screen.view()
        }
    }
}

#Preview {
    ContentView()
//        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
