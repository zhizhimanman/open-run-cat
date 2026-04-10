// OpenRunCat/Models/Runner.swift

import Foundation
import AppKit

struct Runner: Identifiable {
    let id: String
    let name: String
    let frameCount: Int
    let frames: [NSImage]
    let framePaths: [URL]
    let isBuiltIn: Bool

    init(id: String, name: String, framePaths: [URL], isBuiltIn: Bool) {
        self.id = id
        self.name = name
        self.framePaths = framePaths
        self.frameCount = framePaths.count
        self.frames = framePaths.map { NSImage(contentsOf: $0) ?? NSImage() }
        self.isBuiltIn = isBuiltIn
    }
}