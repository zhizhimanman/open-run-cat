// OpenRunCat/Models/Runner.swift

import Foundation
import AppKit

struct Runner: Identifiable {
    let id: String
    let name: String
    let displayName: String
    let frameCount: Int
    let frames: [NSImage]
    let framePaths: [URL]
    let isBuiltIn: Bool

    init(id: String, name: String, framePaths: [URL], isBuiltIn: Bool) {
        self.id = id
        self.name = name
        self.displayName = Runner.getChineseName(for: name)
        self.framePaths = framePaths
        self.frameCount = framePaths.count
        self.frames = framePaths.map { NSImage(contentsOf: $0) ?? NSImage() }
        self.isBuiltIn = isBuiltIn
    }

    // 中文名称映射
    static func getChineseName(for name: String) -> String {
        let nameMap: [String: String] = [
            // 赛博螃蟹系列
            "CyberCrab-NeonPink": "霓虹粉螃蟹",
            "CyberCrab-NeonCyan": "霓虹青螃蟹",
            "CyberCrab-NeonGreen": "霓虹绿螃蟹",
            "CyberCrab-NeonPurple": "霓虹紫螃蟹",
            "CyberCrab-ElectricBlue": "电光蓝螃蟹",
            "CyberCrab-HotPink": "热粉螃蟹",

            // 赛博猫系列
            "CyberCat-Neon": "霓虹猫",
            "CyberCat-Matrix": "黑客帝国猫",

            // 赛博幽灵系列
            "CyberGhost-Purple": "紫色幽灵",
            "CyberGhost-Green": "绿色幽灵",

            // 赛博机器人系列
            "CyberBot-Blue": "蓝色机器人",
            "CyberBot-Red": "红色机器人",

            // 赛博火箭系列
            "CyberRocket-Gold": "金色火箭",
            "CyberRocket-Cyan": "青色火箭",

            // 赛博UFO系列
            "CyberUFO-Classic": "经典飞碟",
            "CyberUFO-Pink": "粉色飞碟",

            // Claude Code 小螃蟹
            "ClaudeCrab-SideRun": "小螃蟹-奔跑",
            "ClaudeCrab-ClawWave": "小螃蟹-挥爪",
            "ClaudeCrab-BounceHop": "小螃蟹-跳跃",

            // 原始小猫
            "Cat": "小猫",
        ]

        return nameMap[name] ?? name
    }
}