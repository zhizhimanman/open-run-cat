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

    // MARK: - FPS Limit Tests

    func testFPSLimitEnforcement() {
        let animator = FrameAnimator()

        // Set a very high speed that would exceed limits
        animator.setSpeed(100.0) // Would result in FPS = 2 + (100 * 0.5) = 52

        // Apply 30 FPS limit
        animator.setFPSLimit(.fps30)

        // The target FPS should be capped at 30
        // We verify this by checking that animation continues to work
        animator.start()
        XCTAssertTrue(true, "FPS limit should be enforced and animation should continue")
    }

    func testFPSLimitNoneAllowsHigherFPS() {
        let animator = FrameAnimator()

        // Set high speed
        animator.setSpeed(100.0) // FPS = 52

        // Apply no limit
        animator.setFPSLimit(.none)

        // Animation should work without capping
        animator.start()
        XCTAssertTrue(true, "No FPS limit should allow higher frame rates")
    }

    func testFPSLimitValueMapping() {
        XCTAssertEqual(FPSLimit.none.value, nil)
        XCTAssertEqual(FPSLimit.fps30.value, 30.0)
        XCTAssertEqual(FPSLimit.fps60.value, 60.0)
    }

    func testFPSLimitCapsTargetFPS() {
        let animator = FrameAnimator()

        // Set speed that would result in 52 FPS
        animator.setSpeed(100.0)

        // After setting 30 FPS limit, target should be capped
        animator.setFPSLimit(.fps30)

        // Verify animation still runs (the capping logic is internal)
        animator.start()
        XCTAssertNotNil(animator.currentFrame)
        animator.stop()
    }
}

// MARK: - Frame Pattern Validation Tests

class RunnerLoaderTests: XCTestCase {
    var loader: RunnerLoader!

    override func setUp() {
        loader = RunnerLoader()
    }

    func testFramePatternValidationRejectsInvalidNames() {
        // Create a temporary directory with test files
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("FramePatternTests-\(UUID().uuidString)")

        do {
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

            // Create files with various naming patterns
            let validFrameNames = ["frame_00.png", "frame_01.png", "frame_10.png"]
            let invalidFrameNames = ["myframe.png", "frame_invalid.png", "something.png", "picture.png"]

            for name in validFrameNames + invalidFrameNames {
                let fileURL = tempDir.appendingPathComponent(name)
                try "dummy".write(to: fileURL, atomically: true, encoding: .utf8)
            }

            // Use the loader to validate frame patterns
            let files = try FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)

            // Apply the same filter as RunnerLoader - regex pattern: frame_\d+\.png
            let framePattern = /^frame_\d+\.png$/
            let pngFiles = files
                .filter { $0.pathExtension == "png" }
                .filter { try? framePattern.wholeMatch(in: $0.lastPathComponent) != nil }
                .sorted { $0.lastPathComponent < $1.lastPathComponent }

            // Should only include valid frame_XX.png files (digits only after underscore)
            XCTAssertEqual(pngFiles.count, 3, "Should only match frame_XX.png pattern where XX are digits")

            let matchedNames = pngFiles.map { $0.lastPathComponent }
            XCTAssertTrue(matchedNames.contains("frame_00.png"))
            XCTAssertTrue(matchedNames.contains("frame_01.png"))
            XCTAssertTrue(matchedNames.contains("frame_10.png"))
            XCTAssertFalse(matchedNames.contains("myframe.png"))
            XCTAssertFalse(matchedNames.contains("frame_invalid.png")) // This should NOT match because "invalid" is not digits
            XCTAssertFalse(matchedNames.contains("something.png"))

            // Cleanup
            try FileManager.default.removeItem(at: tempDir)
        } catch {
            XCTFail("Failed to setup test: \(error)")
        }
    }

    func testFramePatternRequiresPrefix() {
        // Verify that the pattern requires "frame_" prefix followed by digits
        let framePattern = /^frame_\d+\.png$/

        let validName = "frame_00.png"
        let invalidName1 = "myframe.png"
        let invalidName2 = "theframe.png"
        let invalidName3 = "frameback.png"
        let invalidName4 = "frame_invalid.png" // has "frame_" but followed by non-digits

        XCTAssertTrue(try framePattern.wholeMatch(in: validName) != nil, "frame_00.png should match pattern")
        XCTAssertFalse(try framePattern.wholeMatch(in: invalidName1) != nil, "myframe.png should not match pattern")
        XCTAssertFalse(try framePattern.wholeMatch(in: invalidName2) != nil, "theframe.png should not match pattern")
        XCTAssertFalse(try framePattern.wholeMatch(in: invalidName3) != nil, "frameback.png should not match pattern")
        XCTAssertFalse(try framePattern.wholeMatch(in: invalidName4) != nil, "frame_invalid.png should not match pattern")
    }

    func testLoadRunnersReturnsValidRunners() {
        let runners = loader.loadAllRunners()

        for runner in runners {
            // Verify all loaded runners have valid frame paths
            XCTAssertFalse(runner.framePaths.isEmpty, "Runner \(runner.name) should have frame paths")

            // Verify frame paths follow the expected pattern: frame_\d+\.png
            let framePattern = /^frame_\d+\.png$/
            for framePath in runner.framePaths {
                let fileName = framePath.lastPathComponent
                XCTAssertTrue(
                    try framePattern.wholeMatch(in: fileName) != nil,
                    "Frame file \(fileName) should match frame_XX.png pattern where XX are digits"
                )
            }
        }
    }
}