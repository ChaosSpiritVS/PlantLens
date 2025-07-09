//
//  Pla_PermissionManager.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/9.
//

import AVFoundation
import Photos
import SwiftUI

enum Pla_PermissionType {
    case camera
    case photoLibrary
    case microphone
}

final class Pla_PermissionManager: ObservableObject {
    static let shared = Pla_PermissionManager()

    @Published var showSettingsAlert = false
    private var currentPermission: Pla_PermissionType?

    private init() {}

    func check(_ type: Pla_PermissionType, onDenied: (() -> Void)? = nil, onGranted: @escaping () -> Void) {
        currentPermission = type
        switch type {
        case .camera:
            checkCamera(onDenied: onDenied, onGranted: onGranted)
        case .photoLibrary:
            checkPhotoLibrary(onDenied: onDenied, onGranted: onGranted)
        case .microphone:
            checkMicrophone(onDenied: onDenied, onGranted: onGranted)
        }
    }

    private func checkCamera(onDenied: (() -> Void)?, onGranted: @escaping () -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            onGranted()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    granted ? onGranted() : (onDenied?() ?? self.showSettings())
                }
            }
        default:
            onDenied?() ?? showSettings()
        }
    }

    private func checkPhotoLibrary(onDenied: (() -> Void)?, onGranted: @escaping () -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            onGranted()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    (newStatus == .authorized || newStatus == .limited) ? onGranted() : (onDenied?() ?? self.showSettings())
                }
            }
        default:
            onDenied?() ?? showSettings()
        }
    }

    private func checkMicrophone(onDenied: (() -> Void)?, onGranted: @escaping () -> Void) {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            onGranted()
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    granted ? onGranted() : (onDenied?() ?? self.showSettings())
                }
            }
        default:
            onDenied?() ?? showSettings()
        }
    }

    private func showSettings() {
        self.showSettingsAlert = true
    }

    func openSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }
}
