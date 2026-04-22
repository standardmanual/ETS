//
//  ETSApp.swift
//  ETS
//
//  Created by Claude on 2026-04-22.
//

import SwiftUI

@main
struct ETSApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            TabView {
                MetronomeView()
                    .tabItem {
                        Label("메트로놈", systemImage: "metronome")
                    }

                PriorityView()
                    .tabItem {
                        Label("우선순위", systemImage: "guitars")
                    }

                TonesView()
                    .tabItem {
                        Label("코드암기", systemImage: "music.note")
                    }
            }
            .environmentObject(appState)
        }
    }
}
