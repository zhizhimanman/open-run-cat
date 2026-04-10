// OpenRunCat/Runner/RunnerLoader.swift

import Foundation
import AppKit

class RunnerLoader {
    func loadAllRunners() -> [Runner] {
        var runners: [Runner] = []

        // 加载内置角色 - 自动扫描 Runners 目录
        if let resourcePath = Bundle.main.resourcePath {
            let runnersPath = URL(fileURLWithPath: resourcePath).appendingPathComponent("Runners")

            if let enumerator = FileManager.default.enumerator(at: runnersPath, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles]) {
                for case let folderURL as URL in enumerator {
                    let resourceValues = try? folderURL.resourceValues(forKeys: [.isDirectoryKey])
                    guard let isDirectory = resourceValues?.isDirectory, isDirectory else { continue }

                    let runner = loadRunnerFromFolder(folderURL, isBuiltIn: true)
                    if let runner = runner {
                        runners.append(runner)
                    }
                }
            }
        }

        // 加载自定义角色
        let customRunners = loadCustomRunners()
        runners.append(contentsOf: customRunners)

        // 按中文名称排序
        runners.sort { $0.displayName < $1.displayName }

        return runners
    }

    private func loadCustomRunners() -> [Runner] {
        var runners: [Runner] = []

        let customPathString = Constants.customRunnersPath.replacingOccurrences(of: "~", with: NSHomeDirectory())
        let customPath = URL(fileURLWithPath: customPathString)

        guard FileManager.default.fileExists(atPath: customPath.path) else { return runners }
        guard let enumerator = FileManager.default.enumerator(at: customPath, includingPropertiesForKeys: [.isDirectoryKey]) else { return runners }

        for case let folderURL as URL in enumerator {
            let resourceValues = try? folderURL.resourceValues(forKeys: [.isDirectoryKey])
            guard let isDirectory = resourceValues?.isDirectory, isDirectory else { continue }

            let runner = loadRunnerFromFolder(folderURL, isBuiltIn: false)
            if let runner = runner {
                runners.append(runner)
            }
        }

        return runners
    }

    private func loadRunnerFromFolder(_ folder: URL, isBuiltIn: Bool) -> Runner? {
        let runnerName = folder.lastPathComponent
        let framePaths = loadFramePaths(from: folder)

        guard !framePaths.isEmpty else { return nil }

        return Runner(
            id: isBuiltIn ? "builtin-\(runnerName)" : "custom-\(runnerName)",
            name: runnerName,
            framePaths: framePaths,
            isBuiltIn: isBuiltIn
        )
    }

    private func loadFramePaths(from folder: URL) -> [URL] {
        guard let files = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil) else { return [] }

        // Pattern: frame_XX.png where XX is one or more digits
        let framePattern = /^frame_\d+\.png$/

        let pngFiles = files
            .filter { $0.pathExtension == "png" }
            .filter { (try? framePattern.wholeMatch(in: $0.lastPathComponent)) != nil }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }

        return pngFiles
    }
}