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
    func saveButtonDisabled_returnsTrue_whenTitleAndTagsAreSame() {
        let dependency = Dependency()

        let tagA = Tag(title: "A", color: "#FF0000", order: 1)
        let tagB = Tag(title: "B", color: "#00FF00", order: 2)

        let result = dependency.testTarget.saveButtonDisabled(
            originalTitle: "keyword",
            editingTitle: "keyword",
            originalTags: [tagA, tagB],
            editingTags: [tagA, tagB]
        )

        #expect(result == true)
    }

    @MainActor
    @Test
    func saveButtonDisabled_returnsFalse_whenTitleIsDifferent() {
        let dependency = Dependency()

        let result = dependency.testTarget.saveButtonDisabled(
            originalTitle: "keyword",
            editingTitle: "keyword updated",
            originalTags: [],
            editingTags: []
        )

        #expect(result == false)
    }

    @MainActor
    @Test
    func saveButtonDisabled_returnsFalse_whenTagsAreDifferent() {
        let dependency = Dependency()

        let tagA = Tag(title: "A", color: "#FF0000", order: 1)
        let tagB = Tag(title: "B", color: "#00FF00", order: 2)

        let result = dependency.testTarget.saveButtonDisabled(
            originalTitle: "keyword",
            editingTitle: "keyword",
            originalTags: [tagA],
            editingTags: [tagA, tagB]
        )

        #expect(result == false)
    }

    @MainActor
    @Test
    func hasFilteringCondition_returnsFalse_whenTitleAndTagsAreEmpty() {
        let dependency = Dependency()

        let result = dependency.testTarget.hasFilteringCondition(
            title: "",
            tags: []
        )

        #expect(result == false)
    }

    @MainActor
    @Test
    func hasFilteringCondition_returnsTrue_whenTitleExists() {
        let dependency = Dependency()

        let result = dependency.testTarget.hasFilteringCondition(
            title: "keyword",
            tags: []
        )

        #expect(result == true)
    }

    @MainActor
    @Test
    func hasFilteringCondition_returnsTrue_whenTagsExist() {
        let dependency = Dependency()

        let tagA = Tag(title: "A", color: "#FF0000", order: 1)
        let result = dependency.testTarget.hasFilteringCondition(
            title: "",
            tags: [tagA]
        )

        #expect(result == true)
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
