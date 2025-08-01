//
//  Pla_CameraViewModel.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/8.
//

import SwiftUI
import AVFoundation
import PhotosUI

class Pla_CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @Published var session = AVCaptureSession()
    @Published var isFlashOn = false
    @Published var zoom: CGFloat = 1.0 {
        didSet {
            updateZoomLevel()
        }
    }
    @Published var isImproveAccuracy = false {
        didSet {
            print("🌿 提高准确性：\(isImproveAccuracy ? "开启" : "关闭")")
            // 可以在这里触发增强识别逻辑
        }
    }
    @Published var style = Pla_CameraViewStyle()
    @Published var selectedImage: UIImage? = nil          // ✅ 用户选中的图片
    @Published var showImagePicker = false                // ✅ 是否显示相册
    @Published var pickerSourceType: UIImagePickerController.SourceType = .photoLibrary

    var onPhotoCaptured: ((UIImage) -> Void)?

    private var photoOutput = AVCapturePhotoOutput()
    private var currentDeviceInput: AVCaptureDeviceInput?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    private let sessionQueue = DispatchQueue(label: "Pla_CameraSession")

    // MARK: - 相机初始化
    func configure() {
        sessionQueue.async {
            self.session.beginConfiguration()

            // 输入
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                print("❌ 无法找到摄像头")
                return
            }
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                    self.currentDeviceInput = input
                }
            } catch {
                print("❌ 添加输入失败：\(error)")
            }

            // 输出
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
            }

            self.session.commitConfiguration()
            self.session.startRunning()
        }
    }

    func stopSession() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    // MARK: - 拍照
    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = isFlashOn ? .on : .off
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let uiImage = UIImage(data: data) else {
            print("❌ 无法获取拍照数据")
            return
        }
                
        onPhotoCaptured?(uiImage)
    }
    
    // MARK: - 调用图库
    func pickImageFromLibrary() {
        DispatchQueue.main.async {
            self.pickerSourceType = .photoLibrary
            self.showImagePicker = true
        }
    }

    // MARK: - UIImagePickerController Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            DispatchQueue.main.async {
                self.selectedImage = image
                self.onPhotoCaptured?(image)
            }
        }
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    // MARK: - 开关闪光灯
    func toggleFlash() {
        isFlashOn.toggle()
        print("⚡️ 闪光灯状态：\(isFlashOn ? "开" : "关")")
    }

    // MARK: - 切换前后摄像头
    func switchCamera() {
        sessionQueue.async {
            guard let currentInput = self.currentDeviceInput else { return }
            self.session.beginConfiguration()
            self.session.removeInput(currentInput)

            let newPosition: AVCaptureDevice.Position = (currentInput.device.position == .back) ? .front : .back

            guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) else {
                print("❌ 无法切换摄像头")
                self.session.addInput(currentInput)
                self.session.commitConfiguration()
                return
            }

            do {
                let newInput = try AVCaptureDeviceInput(device: newDevice)
                if self.session.canAddInput(newInput) {
                    self.session.addInput(newInput)
                    self.currentDeviceInput = newInput
                } else {
                    self.session.addInput(currentInput)
                }
            } catch {
                print("❌ 切换摄像头失败：\(error)")
                self.session.addInput(currentInput)
            }

            self.session.commitConfiguration()
        }
    }

    // MARK: - 更新焦距
    private func updateZoomLevel() {
        guard let device = currentDeviceInput?.device else { return }
        do {
            try device.lockForConfiguration()
            let clampedZoom = max(1.0, min(zoom, device.activeFormat.videoMaxZoomFactor))
            device.videoZoomFactor = clampedZoom
            device.unlockForConfiguration()
            print("🔍 当前焦距：\(clampedZoom)x")
        } catch {
            print("❌ 设置焦距失败：\(error)")
        }
    }

    // MARK: - 关闭页面
    func close() {
        Pla_AppCoordinator.shared.dismiss(.camera)
    }
    
}
