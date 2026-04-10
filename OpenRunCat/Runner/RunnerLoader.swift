// OpenRunCat/Runner/RunnerLoader.swift

import Foundation
import AppKit

class RunnerLoader {
    func loadAllRunners() -> [Runner] {
        var runners: [Runner] = []

        // 加载内置角色
        let builtInRunners = loadBuiltInRunners()
        runners.append(contentsOf: builtInRunners)

        // 加载自定义角色
        let customRunners = loadCustomRunners()
        runners.append(contentsOf: customRunners)

        return runners
    }

    private func loadBuiltInRunners() -> [Runner] {
        var runners: [Runner] = []

        guard let resourcePath = Bundle.main.resourcePath else { return runners }
        let runnersPath = URL(fileURLWithPath: resourcePath).appendingPathComponent(Constants.builtInRunnersPath)

        guard let enumerator = FileManager.default.enumerator(at: runnersPath, includingPropertiesForKeys: [.isDirectoryKey]) else { return runners }

        for case let folderURL as URL in enumerator {
            guard let isDirectory = try? folderURL.resourceValue(forKey: .isDirectoryKey) as Bool, isDirectory else { continue }

            let runner = loadRunnerFromFolder(folderURL, isBuiltIn: true)
            if let runner = runner {
                runners.append(runner)
            }
        }

        return runners
    }

    private func loadCustomRunners() -> [Runner] {
        var runners: [Runner] = []

        let customPathString = Constants.customRunnersPath.replacingOccurrences(of: "~", with: NSHomeDirectory())
        let customPath = URL(fileURLWithPath: customPathString)

        guard FileManager.default.fileExists(atPath: customPath.path) else { return runners }
        guard let enumerator = FileManager.default.enumerator(at: customPath, includingPropertiesForKeys: [.isDirectoryKey]) else { return runners }

        for case let folderURL as URL in enumerator {
            guard let isDirectory = try? folderURL.resourceValue(forKey: .isDirectoryKey) as Bool, isDirectory else { continue }

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

        let pngFiles = files
            .filter { $0.pathExtension == "png" }
            .filter { $0.lastPathComponent.contains("frame") }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }

        return pngFiles
    }
}