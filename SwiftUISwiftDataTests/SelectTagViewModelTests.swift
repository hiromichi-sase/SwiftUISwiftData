//
//  SelectTagViewModelTests.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import Foundation
import SwiftData
import Testing

@testable import SwiftUISwiftData

struct SelectTagViewModelTests {
    @MainActor
    @Test
    func getTitleLineLimit() {
        let titleLineLimit = 3
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setTitleLineLimit(titleLineLimit)
        #expect(dependency.testTarget.titleLineLimit == titleLineLimit)
    }

    @MainActor
    @Test
    func getTitleFontSize() {
        let titleFontSize = Float(16.0)
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setTitleFontSize(titleFontSize)
        #expect(dependency.testTarget.titleFontSize == titleFontSize)
    }

    @MainActor
    @Test
    func getTitleLineSpacing() {
        let titleLineSpacing = Float.zero
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setTitleLineSpacing(titleLineSpacing)
        #expect(dependency.testTarget.titleLineSpacing == titleLineSpacing)
    }

    @MainActor
    @Test
    func toggleSelection_insertsID_whenNotSelected() {
        let dependency = Dependency()
        let id = UUID()
        var selection: Set<UUID> = []

        dependency.testTarget.toggleSelection(&selection, for: id)

        #expect(selection.contains(id) == true)
    }

    @MainActor
    @Test
    func toggleSelection_removesID_whenAlreadySelected() {
        let dependency = Dependency()
        let id = UUID()
        var selection: Set<UUID> = [id]

        dependency.testTarget.toggleSelection(&selection, for: id)

        #expect(selection.contains(id) == false)
    }

    @MainActor
    @Test
    func selectedTags_returnsOnlyMatchedTags() {
        let dependency = Dependency()

        let tagA = Tag(title: "A", color: "#FF0000", order: 1)
        let tagB = Tag(title: "B", color: "#00FF00", order: 2)
        let tagC = Tag(title: "C", color: "#0000FF", order: 3)

        let testTarget = SelectTagViewModel(
            tags: [tagA, tagB, tagC],
            userDefaultsRepository: dependency.userDefaultsRepository
        )

        let selection: Set<UUID> = [tagA.id, tagC.id]
        let result = testTarget.selectedTags(from: selection)

        #expect(result.count == 2)
        #expect(result.map(\.id).contains(tagA.id) == true)
        #expect(result.map(\.id).contains(tagC.id) == true)
        #expect(result.map(\.id).contains(tagB.id) == false)
    }

    @MainActor
    @Test
    func selectedIDs_returnsAllTagIDs() {
        let dependency = Dependency()

        let tagA = Tag(title: "A", color: "#FF0000", order: 1)
        let tagB = Tag(title: "B", color: "#00FF00", order: 2)
        let tagC = Tag(title: "C", color: "#0000FF", order: 3)

        let testTarget = SelectTagViewModel(
            tags: [tagA, tagB, tagC],
            userDefaultsRepository: dependency.userDefaultsRepository
        )

        let result = testTarget.selectedIDs(from: [tagA, tagB, tagC])

        #expect(result.count == 3)
        #expect(result.contains(tagA.id) == true)
        #expect(result.contains(tagB.id) == true)
        #expect(result.contains(tagC.id) == true)
    }

    @MainActor
    @Test
    func selectedIDs_returnsEmptySet_whenInputIsEmpty() {
        let dependency = Dependency()

        let testTarget = SelectTagViewModel(
            tags: [],
            userDefaultsRepository: dependency.userDefaultsRepository
        )

        let result = testTarget.selectedIDs(from: [])

        #expect(result.isEmpty == true)
    }
}

extension SelectTagViewModelTests {
    struct Dependency {
        let testTarget: SelectTagViewModel
        let userDefaultsRepository: UserDefaultsRepository
        private let support: TestDependencySupport

        @MainActor
        init() {
            let support = TestDependencySupport()
            self.support = support
            userDefaultsRepository = support.userDefaultsRepository

            let modelContainerManager = ModelContainerManager(isStoredInMemoryOnly: true)
            let tagRepository = TagRepository(modelContext: modelContainerManager.modelContainer.mainContext)

            testTarget = .init(
                tagRepository: tagRepository,
                userDefaultsRepository: userDefaultsRepository
            )
        }

        func removeUserDefaults() {
            support.removeUserDefaults()
        }
    }
}
