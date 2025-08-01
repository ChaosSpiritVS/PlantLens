//
//  Pla_RecognitionView.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/9.
//

import SwiftUI

struct Pla_RecognitionView: View {
    let image: UIImage

    @StateObject private var viewModel = Pla_RecognitionViewModel()
    @State private var imageScale: CGFloat = 1.0
    @State private var imageOffset: CGSize = .zero

    let targetWidth: CGFloat = 220
    var targetHeight: CGFloat { targetWidth * 16 / 9 }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack {
                Spacer()

                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        .scaleEffect(imageScale)
                        .offset(imageOffset)
                        .animation(.easeInOut(duration: 0.8), value: imageScale)
                        .animation(.easeInOut(duration: 0.8), value: imageOffset)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.green.opacity(0.2),
                                    Color.green.opacity(0.6),
                                    Color.green.opacity(0.2)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: targetWidth, height: targetHeight * 0.2)
                        .offset(y: (targetHeight * (viewModel.progress - 1)))
                        .opacity(imageScale < 1.0 ? 1 : 0)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .allowsHitTesting(false)
                }
                .frame(width: targetWidth, height: targetHeight)

                Spacer()

                ZStack {
                    Circle()
                        .stroke(lineWidth: 8)
                        .opacity(0.3)
                        .foregroundColor(.green)

                    Circle()
                        .trim(from: 0, to: viewModel.progress / 2)
                        .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .foregroundColor(.green)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 2), value: viewModel.progress)

                    Image("app_logo")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .frame(width: 80, height: 80)
                .padding(.bottom, 50)
            }

            VStack {
                HStack {
                    Button(action: {
                        viewModel.cancelRecognition()
                        Pla_AppCoordinator.shared.dismiss(.recognition)
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                            .padding(12)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.top, 50)

                Spacer()
            }
        }
        .onAppear {
            Pla_AppCoordinator.shared.dismiss(.camera)
            startAnimationAndRecognition()
        }
    }

    private func startAnimationAndRecognition() {
        withAnimation(.easeInOut(duration: 0.8)) {
            imageScale = targetWidth / UIScreen.main.bounds.width
            imageOffset = CGSize(
                width: 0,
                height: -(UIScreen.main.bounds.height / 2 - targetHeight / 2 - 80)
            )
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            viewModel.startRecognition(for: image) { result in
                Pla_AppCoordinator.shared.present(.plantDetail(result))
            }
        }
    }
}
