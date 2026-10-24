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

        guard let newTag = try dependency.tagRepository.tags().first else {
            throw TestError(message: "Tag was not added to the tagRepository.")
        }

        #expect(try dependency.tagRepository.tags().count == 1)
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

        guard let newTag = try dependency.tagRepository.tags().first else {
            throw TestError(message: "Tag was not added to the tagRepository.")
        }

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
        private let userDefaults: UserDefaults
        let userDefaultsRepository: UserDefaultsRepository
        private let suiteName = UUID().uuidString

        @MainActor
        init() throws {
            container = try ModelContainer(
                for: Memo.self,
                Tag.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )

            tagRepository = .init(modelContext: container.mainContext)
            guard let userDefaults = UserDefaults(suiteName: suiteName) else {
                fatalError("Could not create UserDefaults")
            }
            self.userDefaults = userDefaults
            userDefaultsRepository = .init(userDefaults: userDefaults)
            testTarget = .init(
                tagRepository: tagRepository,
                userDefaultsRepository: userDefaultsRepository
            )
        }

        func removeUserDefaults() {
            userDefaults.removePersistentDomain(forName: suiteName)
        }
    }
}
