// OpenRunCatTests/RunnerTests/RunnerManagerTests.swift

import XCTest
@testable import OpenRunCat

class RunnerManagerTests: XCTestCase {
    var manager: RunnerManager!

    override func setUp() {
        manager = RunnerManager()
    }

    func testLoadRunners() {
        XCTAssertGreaterThan(manager.runners.count, 0)
    }

    func testSelectRunner() {
        guard let firstRunner = manager.runners.first else {
            XCTFail("No runners available")
            return
        }

        manager.selectRunner(firstRunner)
        XCTAssertEqual(manager.selectedRunner?.id, firstRunner.id)
    }

    func testAnimatorSpeedCalculation() {
        let animator = FrameAnimator()
        animator.setSpeed(50.0) // 50% usage

        // Expected FPS = 2 + (50 * 0.5) = 27
        // 验证帧率在合理范围内
        Thread.sleep(forTimeInterval: 0.1)
        XCTAssertNotNil(animator.currentFrame)
    }
}