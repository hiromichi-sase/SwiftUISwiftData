//
//  MemoRepository.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/04.
//

import Foundation
import SwiftData

final class MemoRepository {
    enum RepositoryError: LocalizedError {
        case pendingChanges

        var errorDescription: String? {
            switch self {
                case .pendingChanges:
                    "Cannot save memos while other unsaved changes exist."
            }
        }
    }

    /// テストでは保存処理を差し替えて、失敗を再現できる。
    typealias SaveHandler = (ModelContext) throws -> Void

    let modelContext: ModelContext

    private let saveHandler: SaveHandler
    private let descriptor = FetchDescriptor<Memo>(
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

    @MainActor
    func memos() throws -> [Memo] {
        try modelContext.fetch(descriptor)
    }

    /// 新規メモとタグを保存する。
    ///
    /// `tags` を指定した場合、コンテキストの未保存変更を確認した後に
    /// 関連付ける。
    func add(_ memo: Memo, tags: [Tag]? = nil) throws {
        try performChanges {
            let now = Date()
            memo.createdAt = now
            memo.updatedAt = now
            memo.order = try memos().count + 1

            modelContext.insert(memo)

            if let tags {
                memo.tags = tags
            }

            try reorder()
        }
    }

    func update(
        _ memo: Memo,
        title: String,
        content: String,
        tags: [Tag]
    ) throws {
        try performChanges {
            memo.title = title
            memo.content = content
            memo.tags = tags
            memo.updatedAt = Date()
        }
    }

    func duplicate(_ sourceMemo: Memo) throws {
        try performChanges {
            let followingMemos = try memos()
                .filter {
                    $0.order > sourceMemo.order
                }

            for memo in followingMemos {
                memo.order += 1
            }

            let now = Date()
            let newMemo = Memo(
                title: sourceMemo.title,
                content: sourceMemo.content,
                createdAt: now,
                updatedAt: now,
                order: sourceMemo.order + 1,
                protected: sourceMemo.protected
            )

            modelContext.insert(newMemo)
            newMemo.tags = sourceMemo.tags
            try reorder()
        }
    }

    func delete(_ memos: [Memo]) throws {
        try performChanges {
            for memo in memos {
                modelContext.delete(memo)
            }
            try reorder()
        }
    }

    func moveMemo(from source: [Int], to destination: Int) throws {
        try performChanges {
            var ordered = try memos()
            ordered.move(fromOffsets: source, toOffset: destination)

            for (index, memo) in ordered.enumerated() {
                memo.order = index + 1
            }
        }
    }

    func protect(_ memos: [Memo]) throws {
        try performChanges {
            for memo in memos {
                memo.protected = true
            }
        }
    }

    func unprotect(_ memos: [Memo]) throws {
        try performChanges {
            for memo in memos {
                memo.protected = false
            }
        }
    }

    /// 保存に失敗した場合、今回の変更をロールバックする。
    private func performChanges(_ changes: () throws -> Void) throws {
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
        for (index, memo) in try memos().enumerated() {
            memo.order = index + 1
        }
    }
}
