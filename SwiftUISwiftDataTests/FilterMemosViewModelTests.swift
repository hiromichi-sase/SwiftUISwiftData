//
//  FilterMemosViewModelTests.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/11/11.
//

import Foundation
import SwiftData
import Testing

@testable import SwiftUISwiftData

struct FilterMemosViewModelTests {
    @MainActor
    @Test
    func titleLineLimit_reflectsUserDefaults() {
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setTitleLineLimit(3)

        #expect(dependency.testTarget.titleLineLimit == 3)
    }

    @MainActor
    @Test
    func titleFontSize_reflectsUserDefaults() {
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        let value: Float = 16.0
        dependency.userDefaultsRepository.setTitleFontSize(value)

        #expect(dependency.testTarget.titleFontSize == value)
    }

    @MainActor
    @Test
    func titleLineSpacing_reflectsUserDefaults() {
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        let value: Float = 2.0
        dependency.userDefaultsRepository.setTitleLineSpacing(value)

        #expect(dependency.testTarget.titleLineSpacing == value)
    }

    @MainActor
    @Test
    func setInitialFilter_setsOriginalAndEditingValues() {
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        let tagA = Tag(title: "A", color: "#FF0000", order: 1)
        let tagB = Tag(title: "B", color: "#00FF00", order: 2)

        dependency.testTarget.setInitialFilter(
            title: "keyword",
            tags: [tagA, tagB]
        )

        #expect(dependency.testTarget.editingTitle == "keyword")
        #expect(
            dependency.testTarget.editingTags.sortedByOrder
                == [tagA, tagB].sortedByOrder
        )
        #expect(dependency.testTarget.saveButtonDisabled)
    }

    @MainActor
    @Test
    func saveButtonDisabled_returnsTrue_whenTitleAndTagsAreSameAsInitial() {
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        let tagA = Tag(title: "A", color: "#FF0000", order: 1)
        let tagB = Tag(title: "B", color: "#00FF00", order: 2)

        dependency.testTarget.setInitialFilter(
            title: "keyword",
            tags: [tagA, tagB]
        )

        #expect(dependency.testTarget.saveButtonDisabled)
    }

    @MainActor
    @Test
    func saveButtonDisabled_returnsFalse_whenTitleIsDifferentFromInitial() {
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.testTarget.setInitialFilter(
            title: "keyword",
            tags: []
        )
        dependency.testTarget.editingTitle = "keyword updated"

        #expect(!dependency.testTarget.saveButtonDisabled)
    }

    @MainActor
    @Test
    func saveButtonDisabled_returnsFalse_whenTagsAreDifferentFromInitial() {
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        let tagA = Tag(title: "A", color: "#FF0000", order: 1)
        let tagB = Tag(title: "B", color: "#00FF00", order: 2)

        dependency.testTarget.setInitialFilter(
            title: "keyword",
            tags: [tagA]
        )
        dependency.testTarget.editingTags = [tagA, tagB]

        #expect(!dependency.testTarget.saveButtonDisabled)
    }

    @MainActor
    @Test
    func hasFilteringCondition_returnsFalse_whenTitleAndTagsAreEmpty() {
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.testTarget.setInitialFilter(
            title: "",
            tags: []
        )

        #expect(!dependency.testTarget.hasFilteringCondition)
    }

    @MainActor
    @Test
    func hasFilteringCondition_returnsTrue_whenTitleExists() {
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.testTarget.setInitialFilter(
            title: "",
            tags: []
        )
        dependency.testTarget.editingTitle = "keyword"

        #expect(dependency.testTarget.hasFilteringCondition)
    }

    @MainActor
    @Test
    func hasFilteringCondition_returnsTrue_whenTagsExist() {
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        let tagA = Tag(title: "A", color: "#FF0000", order: 1)

        dependency.testTarget.setInitialFilter(
            title: "",
            tags: []
        )
        dependency.testTarget.editingTags = [tagA]

        #expect(dependency.testTarget.hasFilteringCondition)
    }

    @MainActor
    @Test
    func buildSaveResult_returnsEditingValuesAndFilteringState() {
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        let tagA = Tag(title: "A", color: "#FF0000", order: 1)

        dependency.testTarget.setInitialFilter(
            title: "",
            tags: []
        )
        dependency.testTarget.editingTitle = "keyword"
        dependency.testTarget.editingTags = [tagA]

        let result = dependency.testTarget.buildSaveResult()

        #expect(result.isFiltering)
        #expect(result.title == "keyword")
        #expect(result.tags.sortedByOrder == [tagA].sortedByOrder)
        #expect(result.selectedMemo == nil)
    }

    @MainActor
    @Test
    func buildSaveResult_returnsFilteringFalse_whenEditingIsEmpty() {
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.testTarget.setInitialFilter(
            title: "",
            tags: []
        )
        dependency.testTarget.editingTitle = ""
        dependency.testTarget.editingTags = []

        let result = dependency.testTarget.buildSaveResult()

        #expect(!result.isFiltering)
        #expect(result.title == "")
        #expect(result.tags.isEmpty)
        #expect(result.selectedMemo == nil)
    }

    @MainActor
    @Test
    func buildResetResult_returnsClearedValues() {
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        let tagA = Tag(title: "A", color: "#FF0000", order: 1)

        dependency.testTarget.setInitialFilter(
            title: "keyword",
            tags: [tagA]
        )
        dependency.testTarget.editingTitle = "keyword updated"
        dependency.testTarget.editingTags = [tagA]

        let result = dependency.testTarget.buildResetResult()

        #expect(!result.isFiltering)
        #expect(result.title == "")
        #expect(result.tags.isEmpty)
        #expect(result.selectedMemo == nil)
    }

    // MARK: - Factory

    @MainActor
    @Test
    func makeSelectTagViewModel_usesInjectedTagsAndPreferences() {
        let tagA = Tag(title: "A", color: "#FF0000", order: 1)
        let tagB = Tag(title: "B", color: "#00FF00", order: 2)
        let dependency = Dependency(tags: [tagA, tagB])
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setTitleLineLimit(4)
        dependency.userDefaultsRepository.setTitleFontSize(24.0)
        dependency.userDefaultsRepository.setTitleLineSpacing(2.0)

        let selectViewModel = dependency.testTarget.makeSelectTagViewModel()

        #expect(selectViewModel.tags == [tagA, tagB])
        #expect(selectViewModel.titleLineLimit == 4)
        #expect(selectViewModel.titleFontSize == 24.0)
        #expect(selectViewModel.titleLineSpacing == 2.0)
    }

    @MainActor
    @Test
    func makeSelectTagViewModel_usesInjectedRepository() throws {
        let support = TestDependencySupport()
        defer { support.removeUserDefaults() }

        let container = try ModelContainer(
            for: Memo.self,
            Tag.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let repository = TagRepository(modelContext: container.mainContext)

        let tagA = Tag(title: "A", color: "#FF0000")
        try repository.add(tagA)

        let filterViewModel = FilterMemosViewModel(
            tagRepository: repository,
            userDefaultsRepository: support.userDefaultsRepository
        )

        // 親 ViewModel の生成後に追加したタグも、
        // 子 ViewModel 生成時に同じ Repository から取得される。
        let tagB = Tag(title: "B", color: "#00FF00")
        try repository.add(tagB)

        support.userDefaultsRepository.setTitleLineLimit(4)
        support.userDefaultsRepository.setTitleFontSize(24.0)
        support.userDefaultsRepository.setTitleLineSpacing(2.0)

        let selectViewModel = filterViewModel.makeSelectTagViewModel()

        #expect(filterViewModel.tags == [tagA])
        #expect(selectViewModel.tags == [tagA, tagB])
        #expect(selectViewModel.titleLineLimit == 4)
        #expect(selectViewModel.titleFontSize == 24.0)
        #expect(selectViewModel.titleLineSpacing == 2.0)
    }
}

extension FilterMemosViewModelTests {
    struct Dependency {
        let testTarget: FilterMemosViewModel
        let userDefaultsRepository: UserDefaultsRepository
        private let support: TestDependencySupport

        @MainActor
        init(tags: [Tag] = []) {
            let support = TestDependencySupport()
            self.support = support
            userDefaultsRepository = support.userDefaultsRepository

            testTarget = FilterMemosViewModel(
                tags: tags,
                userDefaultsRepository: userDefaultsRepository
            )
        }

        func removeUserDefaults() {
            support.removeUserDefaults()
        }
    }
}
