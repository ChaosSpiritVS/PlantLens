import SwiftUI
import Combine

class Pla_RecognitionViewModel: ObservableObject {
    @Published var recognitionResult: Pla_RecognitionResult? = nil
    @Published var isRecognizing = false
    @Published var progress: CGFloat = 0.0

    private var recognitionTask: Task<Void, Never>?

    func startRecognition(for image: UIImage, onComplete: @escaping (Pla_RecognitionResult?) -> Void) {
        isRecognizing = true
        progress = 0.0

        recognitionTask = Task {
            // 🌱 模拟扫描进度动画
            for i in 1...20 {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1秒
                await MainActor.run {
                    self.progress = CGFloat(i) / 20.0
                }
            }

            // 🌱 调用后端 API 上传图片
            await MainActor.run {
                self.performRecognition(image: image, onComplete: onComplete)
            }
        }
    }

    private func performRecognition(image: UIImage, onComplete: @escaping (Pla_RecognitionResult?) -> Void) {
        Task {
            do {
                // 压缩图片（可选）
                guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                    throw NSError(domain: "ImageConversionError", code: -1)
                }

                // 调用后端识别 API
                let response: Pla_RecognitionResponse = try await Pla_NetworkManager.shared.request(
                    Pla_CameraRouter.recognize(imageData: imageData),
                    responseType: Pla_BaseResponse<Pla_RecognitionResponse>.self,
                )

                await MainActor.run {
                    self.isRecognizing = false
                    self.recognitionResult = response.flower
                    onComplete(response.flower)
                }
            } catch {
                print("❌ 植物识别失败: \(error.localizedDescription)")
                await MainActor.run {
                    self.isRecognizing = false
                    self.recognitionResult = .placeholder
                    onComplete(nil)
                }
            }
        }
    }

    func cancelRecognition() {
        recognitionTask?.cancel()
        recognitionTask = nil
        isRecognizing = false
        progress = 0.0
    }
}
