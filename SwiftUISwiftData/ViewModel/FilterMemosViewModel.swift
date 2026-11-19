//
//  FilterMemosViewModel.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/21.
//

import SwiftData

@Observable
@MainActor
final class FilterMemosViewModel {
    struct FilterApplyResult {
        let isFiltering: Bool
        let title: String
        let tags: [Tag]
        let selectedMemo: Memo?
    }

    private let userDefaultsRepository: UserDefaultsRepository
    private let tagRepository: TagRepository

    private(set) var tags: [Tag] = []

    // Original values (for save button enablement)
    private var originalTitle: String = ""
    private var originalTags: [Tag] = []

    // Editing values bound from View
    var editingTitle: String = ""
    var editingTags: [Tag] = []

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

    func setInitialFilter(title: String, tags: [Tag]) {
        originalTitle = title
        originalTags = tags
        editingTitle = title
        editingTags = tags
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

    var saveButtonDisabled: Bool {
        if originalTags.sortedByOrder != editingTags.sortedByOrder { return false }
        if originalTitle != editingTitle { return false }
        return true
    }

    var hasFilteringCondition: Bool {
        !editingTitle.isEmpty || !editingTags.isEmpty
    }

    func buildSaveResult() -> FilterApplyResult {
        FilterApplyResult(
            isFiltering: hasFilteringCondition,
            title: editingTitle,
            tags: editingTags,
            selectedMemo: nil
        )
    }

    func buildResetResult() -> FilterApplyResult {
        FilterApplyResult(
            isFiltering: false,
            title: "",
            tags: [],
            selectedMemo: nil
        )
    }
}
