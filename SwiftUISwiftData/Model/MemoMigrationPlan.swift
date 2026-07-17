//
//  MemoMigrationPlan.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/22.
//

import SwiftData

typealias Memo = MemoSchemaV3.Memo
typealias Tag = MemoSchemaV3.Tag

enum MemoMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [
            MemoSchemaV1.self,
            MemoSchemaV2.self,
            MemoSchemaV3.self,
        ]
    }

    static var stages: [MigrationStage] {
        [
            migrateV1toV2,
            migrateV2toV3,
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

    static let migrateV2toV3 = MigrationStage.custom(
        fromVersion: MemoSchemaV2.self,
        toVersion: MemoSchemaV3.self,
        willMigrate: nil
    ) { context in
        do {
            let memos = try context.fetch(FetchDescriptor<MemoSchemaV3.Memo>())
            for memo in memos {
                memo.tags = []
            }
            let tags = try context.fetch(FetchDescriptor<MemoSchemaV3.Tag>())
            for tag in tags {
                tag.memos = []
            }
            try context.save()
        }
        catch {
            fatalError("Could not migrate memos from v2 to v3: \(error)")
        }
    }
}
