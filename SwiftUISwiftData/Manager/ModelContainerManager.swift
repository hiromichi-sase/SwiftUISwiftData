//
//  ModelContainerManager.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/03.
//

import SwiftData

final class ModelContainerManager {
    static let shared = ModelContainerManager()
    let modelContainer: ModelContainer

    init(isStoredInMemoryOnly: Bool = false) {
        let schema = Schema([
            Memo.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isStoredInMemoryOnly)

        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
