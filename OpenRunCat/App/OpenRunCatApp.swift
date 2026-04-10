//  OpenRunCatApp.swift
//  OpenRunCat

import SwiftUI

@main
struct OpenRunCatApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Menu bar app - 不需要任何窗口
        // 使用空的 WindowGroup 但不显示
        WindowGroup {
            EmptyView()
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 0, height: 0)
        .commands {
            // 隐藏所有菜单命令
            CommandGroup(replacing: .newItem) { }
            CommandGroup(replacing: .sidebar) { }
        }
    }
}