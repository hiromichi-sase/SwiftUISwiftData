//
//  EditTagViewModelTests.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import Foundation
import Testing

@testable import SwiftUISwiftData

struct EditTagViewModelTests {
    @MainActor
    @Test
    func addTag() async throws {
        let dependency = Dependency()
        let addedTitle = "Added Title"
        let addedColor = "#000000"
        let tag = Tag(title: addedTitle, color: addedColor)
        try dependency.testTarget.add(tag)

        guard let newTag = dependency.tagRepository.tags().first else {
            throw TestError(message: "Tag was not added to the tagRepository.")
        }

        #expect(dependency.tagRepository.tags().count == 1)
        #expect(newTag.title == addedTitle)
        #expect(newTag.color == addedColor)
        #expect(newTag.createdAt == newTag.updatedAt)
        #expect(newTag.order == 1)
        dependency.removeUserDefaults()
    }

    @MainActor
    @Test
    func updateTag() async throws {
        let dependency = Dependency()
        let tag = Tag(title: "Test Title", color: "Test Tag")
        try dependency.testTarget.add(tag)

        let updatedTitle = "Updated Title"
        let updatedColor = "#000000"
        try dependency.testTarget.update(tag, title: updatedTitle, color: updatedColor)

        guard let newTag = dependency.tagRepository.tags().first else {
            throw TestError(message: "Tag was not added to the tagRepository.")
        }

        #expect(newTag.title == updatedTitle)
        #expect(newTag.color == updatedColor)
        #expect(newTag.createdAt < newTag.updatedAt)
        dependency.removeUserDefaults()
    }

    @MainActor
    @Test
    func getShowInfo() {
        let hasLink = false
        let dependency = Dependency()
        dependency.userDefaultsRepository.setShowInfo(hasLink)

        #expect(dependency.testTarget.getShowInfo() == hasLink)
        dependency.removeUserDefaults()
    }

    @MainActor
    @Test
    func getDefaultTagColor() {
        let defaultTagColor = "#FF0000"
        let dependency = Dependency()
        dependency.userDefaultsRepository.setDefaultTagColor(defaultTagColor)

        #expect(dependency.testTarget.getDefaultTagColor() == defaultTagColor)
        dependency.removeUserDefaults()
    }
}

extension EditTagViewModelTests {
    struct Dependency {
        let testTarget: EditTagViewModel
        let tagRepository: TagRepository
        private let userDefaults: UserDefaults
        let userDefaultsRepository: UserDefaultsRepository
        private static let suiteName: String = "Test"

        @MainActor
        init() {
            tagRepository = .init(modelContainer: ModelContainerManager(isStoredInMemoryOnly: true).modelContainer)
            guard let userDefaults = UserDefaults(suiteName: EditTagViewModelTests.Dependency.suiteName) else {
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
            userDefaults.removePersistentDomain(forName: EditTagViewModelTests.Dependency.suiteName)
        }
    }
}
