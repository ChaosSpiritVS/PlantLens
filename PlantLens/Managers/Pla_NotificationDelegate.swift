//
//  Pla_NotificationDelegate.swift
//  Xync
//
//  Created by 李杰 on 2025/3/17.
//

import UserNotifications

class Pla_NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = Pla_NotificationDelegate()
    
    // App 运行时收到通知时调用（前台展示）
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("收到通知：\(notification.request.content.body)")
        completionHandler([.banner, .sound]) // iOS 14+ 显示通知横幅
    }
    
    // 用户点击通知时调用
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("用户点击了通知：\(response.notification.request.identifier)")
        completionHandler()
    }
}

