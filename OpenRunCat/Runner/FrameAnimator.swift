// OpenRunCat/Runner/FrameAnimator.swift

import Foundation
import AppKit
import Combine

class FrameAnimator: ObservableObject {
    @Published var currentFrame: NSImage?

    private var frames: [NSImage] = []
    private var currentIndex: Int = 0
    private var timer: Timer?
    private var targetFPS: Double = Constants.baseFPS
    private var fpsLimit: Double? = nil

    func setFrames(_ frames: [NSImage]) {
        self.frames = frames
        currentIndex = 0
        if let firstFrame = frames.first {
            currentFrame = firstFrame
        }
    }

    func setSpeed(_ usage: Double) {
        // 动画帧率 = baseSpeed + (usage × multiplier)
        targetFPS = Constants.baseFPS + (usage * Constants.fpsMultiplier)

        // 应用 FPS 限制
        if let limit = fpsLimit {
            targetFPS = min(targetFPS, limit)
        }

        restartTimer()
    }

    func setFPSLimit(_ limit: FPSLimit) {
        fpsLimit = limit.value
        if let limitValue = fpsLimit {
            targetFPS = min(targetFPS, limitValue)
        }
        restartTimer()
    }

    func start() {
        guard !frames.isEmpty else { return }
        restartTimer()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func restartTimer() {
        timer?.invalidate()

        guard targetFPS > 0 else { return }
        let interval = 1.0 / targetFPS

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.advanceFrame()
        }
    }

    private func advanceFrame() {
        guard !frames.isEmpty else { return }

        currentIndex = (currentIndex + 1) % frames.count
        currentFrame = frames[currentIndex]
    }
}