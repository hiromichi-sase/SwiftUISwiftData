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
    @Test
    func addTag() async throws {
        let dependency = Dependency()
        let addedTitle = "Added Title"
        let addedColor = "#000000"
        let tag = Tag(title: addedTitle, color: addedColor)
        try await dependency.testTarget.add(tag)

        guard let newTag = await dependency.tagRepository.tags().first else {
            throw TestError(message: "Tag was not added to the tagRepository.")
        }

        await #expect(dependency.tagRepository.tags().count == 1)
        #expect(newTag.title == addedTitle)
        #expect(newTag.color == addedColor)
        #expect(newTag.createdAt == newTag.updatedAt)
        #expect(newTag.order == 1)
        dependency.removeUserDefaults()
    }

    @Test
    func updateTag() async throws {
        let dependency = Dependency()
        let tag = Tag(title: "Test Title", color: "Test Tag")
        try await dependency.testTarget.add(tag)

        let updatedTitle = "Updated Title"
        let updatedColor = "#000000"
        try await dependency.testTarget.update(tag, title: updatedTitle, color: updatedColor)

        guard let newTag = await dependency.tagRepository.tags().first else {
            throw TestError(message: "Tag was not added to the tagRepository.")
        }

        #expect(newTag.title == updatedTitle)
        #expect(newTag.color == updatedColor)
        #expect(newTag.createdAt < newTag.updatedAt)
        dependency.removeUserDefaults()
    }

    @Test
    func getShowInfo() {
        let hasLink = false
        let dependency = Dependency()
        dependency.userDefaultsRepository.setShowInfo(hasLink)

        #expect(dependency.testTarget.getShowInfo() == hasLink)
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
