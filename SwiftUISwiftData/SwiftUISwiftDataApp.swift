//
//  SwiftUISwiftDataApp.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/05/04.
//

import SwiftData
import SwiftUI

/// SwiftUISwiftDataApp is the main entry point of the application, responsible for setting up the main window and providing the model container to the views.
@main
struct SwiftUISwiftDataApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(ModelContainerManager.shared.modelContainer)
    }
}
