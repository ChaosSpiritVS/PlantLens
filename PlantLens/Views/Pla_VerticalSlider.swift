//
//  Pla_VerticalSlider.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/9.
//

import SwiftUI

struct Pla_VerticalSlider: View {
    @Binding var value: CGFloat
    var range: ClosedRange<CGFloat> = 1...5
    var step: CGFloat = 0.1
    var thumbColor: Color = .green
    var trackColor: Color = Color.white.opacity(0.4)
    
    let thumbSize: CGFloat = 20      // ✅ 滑块更大
    let trackWidth: CGFloat = 6      // ✅ 滑道更粗
    let hitAreaWidth: CGFloat = 70   // ✅ 点击区域更宽
    let totalHeight: CGFloat = 80    // ✅ 总长度更短

    var body: some View {
        GeometryReader { geo in
            let trackHeight = geo.size.height - thumbSize
            let valueRange = range.upperBound - range.lowerBound

            ZStack(alignment: .bottom) {
                // 🌿 轨道背景
                RoundedRectangle(cornerRadius: trackWidth / 2)
                    .fill(trackColor)
                    .frame(width: trackWidth)

                // 🟢 已滑动部分
                RoundedRectangle(cornerRadius: trackWidth / 2)
                    .fill(thumbColor)
                    .frame(width: trackWidth, height: progress(for: value) * trackHeight)

                // ⚪️ 滑块
                Circle()
                    .fill(thumbColor)
                    .frame(width: thumbSize, height: thumbSize)
                    .offset(y: -progress(for: value) * trackHeight)
            }
            .frame(width: hitAreaWidth) // ✅ 点击区域宽
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let locationY = gesture.location.y - thumbSize / 2
                        let clampedY = max(0, min(trackHeight, locationY))
                        let percent = 1 - (clampedY / trackHeight) // 上滑增大
                        let newValue = range.lowerBound + percent * valueRange
                        value = (newValue / step).rounded() * step
                    }
            )
        }
        .frame(width: hitAreaWidth, height: totalHeight)
    }

    private func progress(for value: CGFloat) -> CGFloat {
        let clamped = min(max(value, range.lowerBound), range.upperBound)
        return (clamped - range.lowerBound) / (range.upperBound - range.lowerBound)
    }
}
