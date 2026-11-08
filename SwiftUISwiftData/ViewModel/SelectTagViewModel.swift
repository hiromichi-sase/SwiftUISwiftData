//
//  SelectTagViewModel.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import Foundation
import SwiftData

@Observable
@MainActor
final class SelectTagViewModel {
    private(set) var tags: [Tag]
    private let tagRepository: TagRepository?
    private let userDefaultsRepository: UserDefaultsRepository

    init(
        tagRepository: TagRepository,
        userDefaultsRepository: UserDefaultsRepository
    ) {
        self.tagRepository = tagRepository
        self.userDefaultsRepository = userDefaultsRepository
        self.tags = (try? tagRepository.tags()) ?? []
    }

    // For tests / previews
    init(
        tags: [Tag],
        userDefaultsRepository: UserDefaultsRepository
    ) {
        self.tagRepository = nil
        self.userDefaultsRepository = userDefaultsRepository
        self.tags = tags
    }

    var titleLineLimit: Int {
        userDefaultsRepository.getTitleLineLimit()
    }

    var titleFontSize: Float {
        userDefaultsRepository.getTitleFontSize()
    }

    var titleLineSpacing: Float {
        userDefaultsRepository.getTitleLineSpacing()
    }

    func toggleSelection(_ selection: inout Set<UUID>, for id: UUID) {
        if selection.contains(id) {
            selection.remove(id)
        }
        else {
            selection.insert(id)
        }
    }

    func selectedTags(from selection: Set<UUID>) -> [Tag] {
        tags.filter { selection.contains($0.id) }
    }

    func selectedIDs(from tags: [Tag]) -> Set<UUID> {
        Set(tags.map(\.id))
    }
}
