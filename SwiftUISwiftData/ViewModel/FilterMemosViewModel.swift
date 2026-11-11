//
//  FilterMemosViewModel.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/21.
//

import Observation
import SwiftData

@Observable
@MainActor
final class FilterMemosViewModel {
    private let userDefaultsRepository: UserDefaultsRepository
    private(set) var tags: [Tag] = []
    private let tagRepository: TagRepository

    init(
        tagRepository: TagRepository,
        userDefaultsRepository: UserDefaultsRepository
    ) {
        self.tagRepository = tagRepository
        self.userDefaultsRepository = userDefaultsRepository
        tags = (try? tagRepository.tags()) ?? []
    }

    // For tests / previews
    init(
        tags: [Tag],
        userDefaultsRepository: UserDefaultsRepository
    ) {
        self.tags = tags
        self.userDefaultsRepository = userDefaultsRepository
        self.tagRepository = TagRepository(
            modelContext: ModelContainerManager.shared.modelContainer.mainContext
        )
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

    func saveButtonDisabled(
        originalTitle: String,
        editingTitle: String,
        originalTags: [Tag],
        editingTags: [Tag]
    ) -> Bool {
        if originalTags.sortedByOrder != editingTags.sortedByOrder { return false }
        if originalTitle != editingTitle { return false }
        return true
    }

    func hasFilteringCondition(title: String, tags: [Tag]) -> Bool {
        !title.isEmpty || !tags.isEmpty
    }
}
