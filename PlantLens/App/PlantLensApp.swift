//
//  PlantLensApp.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/2.
//

import SwiftUI

@main
struct PlantLensApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
