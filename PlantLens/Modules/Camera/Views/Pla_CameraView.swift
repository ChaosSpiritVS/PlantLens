//
//  Pla_CameraView.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/3.
//

import SwiftUI
import AVFoundation

struct Pla_CameraView: View {
    @StateObject private var viewModel = Pla_CameraViewModel()

    var body: some View {
        ZStack {
            // 📷 相机预览层
            Pla_CameraPreview(session: viewModel.session)
                .ignoresSafeArea()
            
            // 🌿 顶部控制按钮
            VStack {
                HStack {
                    // ⬅️ 退出
                    Button(action: { viewModel.close() }) {
                        viewModel.style.iconClose
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }

                    Spacer()

                    // ➡️ 帮助、闪光灯、切换镜头
                    HStack(spacing: 15) {
                        Button(action: { /* 帮助 */ }) {
                            viewModel.style.iconHelp
                        }
                        Button(action: { viewModel.toggleFlash() }) {
                            viewModel.isFlashOn ? viewModel.style.iconFlashOn : viewModel.style.iconFlashOff
                        }
                        Button(action: { viewModel.switchCamera() }) {
                            viewModel.style.iconFlipCamera
                        }
                    }
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)

                Spacer()
            }

            // 🎯 引导框 + 提示 + 开关
            VStack {
                Spacer()

                ZStack {
                    GuideCorners()
                        .stroke(Color.white, lineWidth: 5)
                        .frame(width: 260, height: 260)

                    Text(viewModel.style.tipEnsurePlant)
                        .foregroundColor(.white)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
                
                Spacer()

                Toggle(isOn: $viewModel.isImproveAccuracy) {
                    Text(viewModel.style.buttonImproveAccuracy)
                        .foregroundColor(.white)
                        .font(.footnote)
                }
                .toggleStyle(SwitchToggleStyle(tint: .green))
                .frame(width: 130)
                .font(.title2)
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background(Color.black.opacity(0.5))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.white, lineWidth: 1) // ✅ 白色边框
                )
                .padding(.bottom, 150) // ✅ Toggle 离底部操作栏有间距
            }

            // 🔍 右侧垂直焦距滑块
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Pla_VerticalSlider(value: $viewModel.zoom, range: 1...5, step: 0.1)
                    .padding(.trailing, 8)
                }
            }
            .padding(.bottom, 165) // 调整垂直位置

        
            // 📸 底部操作栏
            VStack {
                Spacer()

                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .frame(height: 120)
                        .ignoresSafeArea(edges: .bottom)
                        .shadow(radius: 5)

                    HStack {
                        // 📂 相册
                        Button(action: {
                            Pla_PermissionManager.shared.check(.photoLibrary) {
                                viewModel.pickImageFromLibrary()
                            }
                        }) {
                            viewModel.style.iconPhoto
                                .font(.title)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .clipShape(Circle())
                        }
                        .withSettingsAlert()

                        Spacer()

                        // 📸 拍照按钮（✅ 改为主题绿色 + 高亮外圈）
                        Button(action: { viewModel.takePhoto() }) {
                            Circle()
                                .fill(Color.green) // ✅ 主题绿色
                                .frame(width: 75, height: 75)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 4) // ✅ 白色外圈
                                )
                                .shadow(color: Color.green.opacity(0.4), radius: 10, x: 0, y: 4) // ✅ 光晕效果
                        }

                        Spacer()

                        // ➕ 备用按钮（✅ 空样式按钮）
                        Button(action: { /* 备用功能未来扩展 */ }) {
                            Image(systemName: "ellipsis") // 三个点占位
                                .font(.title2)
                                .foregroundColor(.gray.opacity(0.5))
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 40)
                }
            }
                        
        }
        .onAppear {
            viewModel.configure()
            viewModel.onPhotoCaptured = { image in
                Pla_AppCoordinator.shared.present(.recognition(image))
            }
            
        }
        .onDisappear {
            viewModel.stopSession()
        }
        .fullScreenCover(isPresented: $viewModel.showImagePicker) {
            NavigationView {
                ImagePicker(
                    isPresented: $viewModel.showImagePicker,
                    sourceType: viewModel.pickerSourceType,
                    delegate: viewModel
                )
                .navigationBarTitle("相册", displayMode: .inline)
                .navigationBarItems(trailing: Button("关闭") {
                    viewModel.showImagePicker = false
                })
            }
        }
        
    }
}

struct GuideCorners: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cornerLength: CGFloat = 30

        // Top-left
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + cornerLength))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + cornerLength, y: rect.minY))

        // Top-right
        path.move(to: CGPoint(x: rect.maxX - cornerLength, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + cornerLength))

        // Bottom-right
        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerLength))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX - cornerLength, y: rect.maxY))

        // Bottom-left
        path.move(to: CGPoint(x: rect.minX + cornerLength, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - cornerLength))

        return path
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var sourceType: UIImagePickerController.SourceType
    var delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = delegate
        picker.allowsEditing = false

        // ✅ 添加一个“取消”按钮
        let closeButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: context.coordinator, action: #selector(Coordinator.dismiss))
        picker.navigationBar.topItem?.rightBarButtonItem = closeButton

        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        let parent: ImagePicker
        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        @objc func dismiss() {
            parent.isPresented = false
        }
    }
}
