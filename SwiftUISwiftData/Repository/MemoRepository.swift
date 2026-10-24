//
//  MemoRepository.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/04.
//

import Foundation
import SwiftData

final class MemoRepository {
    private(set) var modelContext: ModelContext
    private let descriptor = FetchDescriptor<Memo>(sortBy: [SortDescriptor(\.order)])

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func memos() throws -> [Memo] {
        try modelContext.fetch(descriptor)
    }

    func add(_ memo: Memo) throws {
        try modelContext.transaction {
            let now = Date()
            memo.createdAt = now
            memo.updatedAt = now
            memo.order = try memos().count + 1
            modelContext.insert(memo)
            try reorder()
        }
    }

    func update(_ memo: Memo, title: String, content: String, tags: [Tag]) throws {
        try modelContext.transaction {
            memo.title = title
            memo.content = content
            memo.tags = tags
            memo.updatedAt = Date()
        }
    }

    func duplicate(_ sourceMemo: Memo) throws {
        try modelContext.transaction {
            let followingMemos = try memos().filter { $0.order > sourceMemo.order }
            for memo in followingMemos { memo.order += 1 }

            let now = Date()
            let newMemo = Memo(
                title: sourceMemo.title,
                content: sourceMemo.content,
                createdAt: now,
                updatedAt: now,
                order: sourceMemo.order + 1,
                protected: sourceMemo.protected,
                tags: sourceMemo.tags
            )
            modelContext.insert(newMemo)
            try reorder()
        }
    }

    func delete(_ memos: [Memo]) throws {
        try modelContext.transaction {
            for memo in memos { modelContext.delete(memo) }
            try reorder()
        }
    }

    func moveMemo(from source: [Int], to destination: Int) throws {
        try modelContext.transaction {
            var ordered = try memos()
            ordered.move(from: source, to: destination)
            for (index, memo) in ordered.enumerated() {
                memo.order = index + 1
            }
        }
    }

    func protect(_ memos: [Memo]) throws {
        try modelContext.transaction {
            for memo in memos { memo.protected = true }
        }
    }

    func unprotect(_ memos: [Memo]) throws {
        try modelContext.transaction {
            for memo in memos { memo.protected = false }
        }
    }

    private func reorder() throws {
        for (index, memo) in try memos().enumerated() {
            memo.order = index + 1
        }
    }
}
