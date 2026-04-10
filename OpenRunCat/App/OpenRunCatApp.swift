//
//  OpenRunCatApp.swift
//  OpenRunCat
//
//  Created by OpenRunCat Team on 2024.
//

import SwiftUI

@main
struct OpenRunCatApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Menu bar app does not need to show a window
        SwiftUI.Settings {
            EmptyView()
        }
    }
}