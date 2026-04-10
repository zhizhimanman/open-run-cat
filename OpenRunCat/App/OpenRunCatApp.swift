//
//  OpenRunCatApp.swift
//  OpenRunCat
//
//  Created by OpenRunCat Team on 2024.
//

import SwiftUI

@main
struct OpenRunCatApp: App {
    var body: some Scene {
        MenuBarExtra("OpenRunCat", systemImage: "figure.run") {
            ContentView()
        }
        .menuBarExtraStyle(.menu)
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Text("OpenRunCat")
                .font(.headline)
            Text("System Monitor")
                .font(.caption)
            Divider()
            Button("Settings...") {
                // TODO: Open settings window
            }
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}