//
//  PlantLensApp.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/2.
//

import SwiftUI
import UserNotifications
import AppTrackingTransparency
import AdSupport

@main
struct PlantLensApp: App {
//    let persistenceController = PersistenceController.shared
    
    init() {
//        if !AppEnvironment.isPreview {
//            requestNotificationPermission()
//            PlantLensApp.requestTrackingPermission()
//        }
        NavigationConfig.setupGlobalNavigationBar()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
    
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.delegate = Pla_NotificationDelegate.shared
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("用户已授权通知")
            } else {
                print("用户拒绝通知")
            }
        }
    }
    
    static func requestTrackingPermission() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    print("用户允许跟踪，IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
                case .denied:
                    print("用户拒绝跟踪")
                case .notDetermined:
                    print("用户尚未做出选择")
                case .restricted:
                    print("跟踪权限受限")
                @unknown default:
                    print("未知状态")
                }
            }
        }
    }
}
