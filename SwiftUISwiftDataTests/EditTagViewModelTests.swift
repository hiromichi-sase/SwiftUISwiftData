//
//  EditTagViewModelTests.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import Foundation
import SwiftData
import Testing

@testable import SwiftUISwiftData

struct EditTagViewModelTests {
    @MainActor
    @Test
    func addTag() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let addedTitle = "Added Title"
        let addedColor = "#000000"
        let tag = Tag(title: addedTitle, color: addedColor)
        try dependency.testTarget.add(tag)

        let tags = try dependency.tagRepository.tags()
        #expect(tags.count == 1)
        let newTag = try #require(tags.first)

        #expect(newTag.title == addedTitle)
        #expect(newTag.color == addedColor)
        #expect(newTag.createdAt == newTag.updatedAt)
        #expect(newTag.order == 1)
    }

    @MainActor
    @Test
    func updateTag() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let tag = Tag(title: "Test Title", color: "Test Tag")
        try dependency.testTarget.add(tag)

        let updatedTitle = "Updated Title"
        let updatedColor = "#000000"
        try dependency.testTarget.update(tag, title: updatedTitle, color: updatedColor)

        let tags = try dependency.tagRepository.tags()
        #expect(tags.count == 1)
        let newTag = try #require(tags.first)

        #expect(newTag.title == updatedTitle)
        #expect(newTag.color == updatedColor)
        #expect(newTag.createdAt < newTag.updatedAt)
    }

    @MainActor
    @Test
    func getShowInfo() throws {
        let hasLink = false
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }
        dependency.userDefaultsRepository.setShowInfo(hasLink)

        #expect(dependency.testTarget.getShowInfo() == hasLink)
    }

    @MainActor
    @Test
    func getDefaultTagColor() throws {
        let defaultTagColor = "#FF0000"
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }
        dependency.userDefaultsRepository.setDefaultTagColor(defaultTagColor)

        #expect(dependency.testTarget.getDefaultTagColor() == defaultTagColor)
    }
}

extension EditTagViewModelTests {
    struct Dependency {
        private let container: ModelContainer
        let testTarget: EditTagViewModel
        let tagRepository: TagRepository
        let userDefaultsRepository: UserDefaultsRepository
        private let support: TestDependencySupport

        @MainActor
        init() throws {
            let support = TestDependencySupport()
            self.support = support
            userDefaultsRepository = support.userDefaultsRepository

            container = try ModelContainer(
                for: Memo.self,
                Tag.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )

            tagRepository = .init(modelContext: container.mainContext)

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
