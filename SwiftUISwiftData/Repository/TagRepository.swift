//
//  TagRepository.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import Foundation
import SwiftData

final class TagRepository {
    enum RepositoryError: LocalizedError {
        case pendingChanges

        var errorDescription: String? {
            switch self {
                case .pendingChanges:
                    "Cannot save tags while other unsaved changes exist."
            }
        }
    }

    /// テストでは保存処理を差し替えて、失敗を再現できる。
    typealias SaveHandler = (ModelContext) throws -> Void

    let modelContext: ModelContext

    private let saveHandler: SaveHandler
    private let descriptor = FetchDescriptor<Tag>(
        sortBy: [SortDescriptor(\.order)]
    )

    init(
        modelContext: ModelContext,
        saveHandler: @escaping SaveHandler = { context in
            try context.save()
        }
    ) {
        self.modelContext = modelContext
        self.saveHandler = saveHandler
    }

    func tags() throws -> [Tag] {
        try modelContext.fetch(descriptor)
    }

    func add(_ tag: Tag) throws {
        try performChanges {
            let now = Date()
            tag.createdAt = now
            tag.updatedAt = now
            tag.order = try tags().count + 1
            modelContext.insert(tag)
            try reorder()
        }
    }

    func update(_ tag: Tag, title: String, color: String) throws {
        try performChanges {
            tag.title = title
            tag.color = color
            tag.updatedAt = Date()
        }
    }

    func delete(_ tags: [Tag]) throws {
        try performChanges {
            for tag in tags {
                modelContext.delete(tag)
            }
            try reorder()
        }
    }

    func moveTag(from source: [Int], to destination: Int) throws {
        try performChanges {
            var ordered = try tags()
            ordered.move(fromOffsets: source, toOffset: destination)
            assignOrder(for: ordered)
        }
    }

    /// 変更を保存し、失敗した場合はコンテキストを元に戻す。
    private func performChanges(_ changes: () throws -> Void) throws {
        // rollback() はコンテキスト内の未保存変更をすべて取り消す。
        // 別の未保存変更を誤って取り消さないよう、処理前に確認する。
        guard !modelContext.hasChanges else {
            throw RepositoryError.pendingChanges
        }

        do {
            try changes()
            try saveHandler(modelContext)
        }
        catch {
            modelContext.rollback()
            throw error
        }
    }

    private func reorder() throws {
        assignOrder(for: try tags())
    }

    private func assignOrder(for tags: [Tag]) {
        for (index, tag) in tags.enumerated() {
            tag.order = index + 1
        }
    }
}
