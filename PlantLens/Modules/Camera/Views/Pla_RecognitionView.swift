//
//  Pla_RecognitionView.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/9.
//

import SwiftUI

struct Pla_RecognitionView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode

    let image: UIImage
    var isFromCamera: Bool = true

    @State private var scanProgress: CGFloat = 0.0
    @State private var showResult = false
    @State private var offsetY: CGFloat = 0

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)

            VStack {
                // Top bar with Close button
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                            .padding(12)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 50)

                Spacer()
            }

            // Image with scanning overlay
            GeometryReader { geo in
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .offset(y: isFromCamera ? 0 : offsetY)
                        .gesture(isFromCamera ? nil : DragGesture()
                            .onChanged { value in
                                offsetY = value.translation.height
                            }
                        )
                        .animation(.easeInOut, value: offsetY)

                    // Four-corner frame
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green, lineWidth: 3)
                        .padding(30)

                    // Scanning line animation
                    Rectangle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.green.opacity(0.4), Color.clear]),
                            startPoint: .top,
                            endPoint: .bottom)
                        )
                        .frame(height: 4)
                        .offset(y: geo.size.height * scanProgress)
                        .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: scanProgress)
                }
            }
            .padding(.horizontal)

            // Circular progress indicator
            VStack {
                Spacer()
                ZStack {
                    Circle()
                        .stroke(lineWidth: 8)
                        .opacity(0.3)
                        .foregroundColor(Color.green)

                    Circle()
                        .trim(from: 0, to: scanProgress)
                        .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .foregroundColor(Color.green)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 2), value: scanProgress)

                    Image("app_logo") // 你的App Logo图片名
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .frame(width: 80, height: 80)
                .padding()

                if !isFromCamera {
                    HStack {
                        Button(action: {
                            // 打开相册逻辑
                        }) {
                            Label("相册", systemImage: "photo.on.rectangle")
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                        Spacer()
                        Button(action: startRecognition) {
                            Image(systemName: "magnifyingglass.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.horizontal, 50)
                    .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            if isFromCamera {
                startRecognition()
            }
        }
        .sheet(isPresented: $showResult) {
            Pla_RecognitionResultView() // 结果页面
        }
    }

    private func startRecognition() {
        scanProgress = 0.0
        withAnimation(.linear(duration: 2)) {
            scanProgress = 1.0
        }
        // 模拟识别完成后弹出结果
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            showResult = true
        }
    }
}

struct Pla_RecognitionResultView: View {
    var body: some View {
        VStack {
            Text("🌿 识别结果")
                .font(.title)
                .padding()

            // 识别结果内容
            Text("植物名：绣球花\n拉丁名：Hydrangea\n描述：一种常见的观赏植物...")
                .padding()

            Spacer()

            Button("关闭") {
                // dismiss sheet
            }
            .padding()
        }
    }
}
