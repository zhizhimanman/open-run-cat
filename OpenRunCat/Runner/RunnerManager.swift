// OpenRunCat/Runner/RunnerManager.swift

import Foundation
import AppKit
import Combine

class RunnerManager: ObservableObject {
    @Published var runners: [Runner] = []
    @Published var selectedRunner: Runner?
    @Published var currentFrame: NSImage?

    private let loader = RunnerLoader()
    private let animator = FrameAnimator()

    init() {
        loadRunners()
        setupBindings()
    }

    func loadRunners() {
        runners = loader.loadAllRunners()
        if let firstRunner = runners.first {
            selectRunner(firstRunner)
        }
    }

    func selectRunner(_ runner: Runner) {
        selectedRunner = runner
        animator.setFrames(runner.frames)
        animator.start()
    }

    func selectRunnerById(_ id: String) {
        guard let runner = runners.first(where: { $0.id == id }) else { return }
        selectRunner(runner)
    }

    private func setupBindings() {
        animator.$currentFrame
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentFrame)
    }

    func updateAnimationSpeed(_ usage: Double) {
        animator.setSpeed(usage)
    }

    func setFPSLimit(_ limit: FPSLimit) {
        animator.setFPSLimit(limit)
    }
}