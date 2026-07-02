//
//  MemoMigrationPlan.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/22.
//

import SwiftData

typealias Memo = MemoSchemaV2.Memo

enum MemoMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [
            MemoSchemaV1.self,
            MemoSchemaV2.self,
        ]
    }

    static var stages: [MigrationStage] {
        [
            migrateV1toV2
        ]
    }

    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: MemoSchemaV1.self,
        toVersion: MemoSchemaV2.self,
        willMigrate: nil
    ) { context in
        do {
            let memos = try context.fetch(FetchDescriptor<MemoSchemaV2.Memo>())
            for memo in memos {
                memo.protected = false
            }
            try context.save()
        }
        catch {
            fatalError("Could not migrate memos from v1 to v2: \(error)")
        }
    }
}
