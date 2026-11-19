//
//  FilterMemosViewModelTests.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/11/11.
//

import Foundation
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
        let tagA = Tag(title: "A", color: "#FF0000", order: 1)
        let tagB = Tag(title: "B", color: "#00FF00", order: 2)

        dependency.testTarget.setInitialFilter(
            title: "keyword",
            tags: [tagA, tagB]
        )

        #expect(dependency.testTarget.editingTitle == "keyword")
        #expect(dependency.testTarget.editingTags.sortedByOrder == [tagA, tagB].sortedByOrder)
        #expect(dependency.testTarget.saveButtonDisabled == true)
    }

    @MainActor
    @Test
    func saveButtonDisabled_returnsTrue_whenTitleAndTagsAreSameAsInitial() {
        let dependency = Dependency()
        let tagA = Tag(title: "A", color: "#FF0000", order: 1)
        let tagB = Tag(title: "B", color: "#00FF00", order: 2)

        dependency.testTarget.setInitialFilter(
            title: "keyword",
            tags: [tagA, tagB]
        )

        #expect(dependency.testTarget.saveButtonDisabled == true)
    }

    @MainActor
    @Test
    func saveButtonDisabled_returnsFalse_whenTitleIsDifferentFromInitial() {
        let dependency = Dependency()

        dependency.testTarget.setInitialFilter(
            title: "keyword",
            tags: []
        )
        dependency.testTarget.editingTitle = "keyword updated"

        #expect(dependency.testTarget.saveButtonDisabled == false)
    }

    @MainActor
    @Test
    func saveButtonDisabled_returnsFalse_whenTagsAreDifferentFromInitial() {
        let dependency = Dependency()
        let tagA = Tag(title: "A", color: "#FF0000", order: 1)
        let tagB = Tag(title: "B", color: "#00FF00", order: 2)

        dependency.testTarget.setInitialFilter(
            title: "keyword",
            tags: [tagA]
        )
        dependency.testTarget.editingTags = [tagA, tagB]

        #expect(dependency.testTarget.saveButtonDisabled == false)
    }

    @MainActor
    @Test
    func hasFilteringCondition_returnsFalse_whenTitleAndTagsAreEmpty() {
        let dependency = Dependency()

        dependency.testTarget.setInitialFilter(
            title: "",
            tags: []
        )

        #expect(dependency.testTarget.hasFilteringCondition == false)
    }

    @MainActor
    @Test
    func hasFilteringCondition_returnsTrue_whenTitleExists() {
        let dependency = Dependency()

        dependency.testTarget.setInitialFilter(
            title: "",
            tags: []
        )
        dependency.testTarget.editingTitle = "keyword"

        #expect(dependency.testTarget.hasFilteringCondition == true)
    }

    @MainActor
    @Test
    func hasFilteringCondition_returnsTrue_whenTagsExist() {
        let dependency = Dependency()
        let tagA = Tag(title: "A", color: "#FF0000", order: 1)

        dependency.testTarget.setInitialFilter(
            title: "",
            tags: []
        )
        dependency.testTarget.editingTags = [tagA]

        #expect(dependency.testTarget.hasFilteringCondition == true)
    }

    @MainActor
    @Test
    func buildSaveResult_returnsEditingValuesAndFilteringState() {
        let dependency = Dependency()
        let tagA = Tag(title: "A", color: "#FF0000", order: 1)

        dependency.testTarget.setInitialFilter(
            title: "",
            tags: []
        )
        dependency.testTarget.editingTitle = "keyword"
        dependency.testTarget.editingTags = [tagA]

        let result = dependency.testTarget.buildSaveResult()

        #expect(result.isFiltering == true)
        #expect(result.title == "keyword")
        #expect(result.tags.sortedByOrder == [tagA].sortedByOrder)
        #expect(result.selectedMemo == nil)
    }

    @MainActor
    @Test
    func buildSaveResult_returnsFilteringFalse_whenEditingIsEmpty() {
        let dependency = Dependency()

        dependency.testTarget.setInitialFilter(
            title: "",
            tags: []
        )
        dependency.testTarget.editingTitle = ""
        dependency.testTarget.editingTags = []

        let result = dependency.testTarget.buildSaveResult()

        #expect(result.isFiltering == false)
        #expect(result.title == "")
        #expect(result.tags.isEmpty)
        #expect(result.selectedMemo == nil)
    }

    @MainActor
    @Test
    func buildResetResult_returnsClearedValues() {
        let dependency = Dependency()
        let tagA = Tag(title: "A", color: "#FF0000", order: 1)

        dependency.testTarget.setInitialFilter(
            title: "keyword",
            tags: [tagA]
        )
        dependency.testTarget.editingTitle = "keyword updated"
        dependency.testTarget.editingTags = [tagA]

        let result = dependency.testTarget.buildResetResult()

        #expect(result.isFiltering == false)
        #expect(result.title == "")
        #expect(result.tags.isEmpty)
        #expect(result.selectedMemo == nil)
    }
}

extension FilterMemosViewModelTests {
    struct Dependency {
        let testTarget: FilterMemosViewModel
        let userDefaultsRepository: UserDefaultsRepository
        private let support: TestDependencySupport

        @MainActor
        init() {
            let support = TestDependencySupport()
            self.support = support
            userDefaultsRepository = support.userDefaultsRepository

            testTarget = .init(
                tags: [],
                userDefaultsRepository: userDefaultsRepository
            )
        }

        func removeUserDefaults() {
            support.removeUserDefaults()
        }
    }
}
