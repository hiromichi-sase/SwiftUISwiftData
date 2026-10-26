//
//  TagRepository.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import Foundation
import SwiftData

final class TagRepository {
    private let modelContext: ModelContext
    private let descriptor = FetchDescriptor<Tag>(sortBy: [SortDescriptor(\.order)])

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func tags() throws -> [Tag] {
        try modelContext.fetch(descriptor)
    }

    func add(_ tag: Tag) throws {
        try modelContext.transaction {
            let now = Date()
            tag.createdAt = now
            tag.updatedAt = now
            tag.order = try tags().count + 1
            modelContext.insert(tag)
            try reorder()
        }
    }

    func update(_ tag: Tag, title: String, color: String) throws {
        try modelContext.transaction {
            tag.title = title
            tag.color = color
            tag.updatedAt = Date()
        }
    }

    func delete(_ tags: [Tag]) throws {
        try modelContext.transaction {
            for tag in tags { modelContext.delete(tag) }
            try reorder()
        }
    }

    func moveTag(from source: [Int], to destination: Int) throws {
        try modelContext.transaction {
            var ordered = try tags()
            ordered.move(fromOffsets: source, toOffset: destination)
            assignOrder(for: ordered)
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
