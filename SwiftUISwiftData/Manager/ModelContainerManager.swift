//
//  ModelContainerManager.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/03.
//

import SwiftData

/// Singleton class to manage the ModelContainer for SwiftData.
final class ModelContainerManager {
    /// Shared instance of the ModelContainerManager.
    static let shared = ModelContainerManager()
    /// The ModelContainer instance that will be used throughout the app.
    let modelContainer: ModelContainer

    /// Initializes the ModelContainerManager with an optional parameter to specify if the data should be stored in memory only.
    /// - Parameter isStoredInMemoryOnly: A Boolean value indicating whether the data should be stored in memory only. Default is `false`.
    init(isStoredInMemoryOnly: Bool = false) {
        let schema = Schema([
            Memo.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isStoredInMemoryOnly)

        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            modelContainer.mainContext.autosaveEnabled = false
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
