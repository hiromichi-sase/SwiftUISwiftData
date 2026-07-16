//
//  TagsViewModelTests.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import Foundation
import Testing

@testable import SwiftUISwiftData

struct TagsViewModelTests {
    @Test
    func deleteTags() async throws {
        let dependency = Dependency()
        let tag1 = Tag(title: "Test Title 1", color: "#FF0000", order: 1)
        let tag2 = Tag(title: "Test Title 2", color: "#00FF00", order: 2)
        let tag3 = Tag(title: "Test Title 3", color: "#0000FF", order: 3)

        try await dependency.tagRepository.add(tag1)
        try await dependency.tagRepository.add(tag2)
        try await dependency.tagRepository.add(tag3)
        try await dependency.testTarget.delete([tag2])

        let tags = await dependency.tagRepository.tags()
        if tags.count > 2 {
            throw TestError(message: "Expected only 2 tags after deletion, but found \(tags.count).")
        }

        #expect(tags[0].order == 1)
        #expect(tags[0].title == "Test Title 1")
        #expect(tags[0].color == "#FF0000")

        #expect(tags[1].order == 2)
        #expect(tags[1].title == "Test Title 3")
        #expect(tags[1].color == "#0000FF")
        dependency.removeUserDefaults()
    }

    @Test
    func moveTag() async throws {
        let dependency = Dependency()
        let tag1 = Tag(title: "Test Title 1", color: "#FF0000", order: 1)
        let tag2 = Tag(title: "Test Title 2", color: "#00FF00", order: 2)
        let tag3 = Tag(title: "Test Title 3", color: "#0000FF", order: 3)

        try await dependency.tagRepository.add(tag1)
        try await dependency.tagRepository.add(tag2)
        try await dependency.tagRepository.add(tag3)
        try await dependency.testTarget.moveTag(from: [2], to: 1)

        let tags = await dependency.tagRepository.tags()
        if tags.count != 3 {
            throw TestError(message: "Expected 3 tags after moving, but found \(tags.count).")
        }

        #expect(tags[0].order == 1)
        #expect(tags[0].title == "Test Title 1")
        #expect(tags[0].color == "#FF0000")

        #expect(tags[1].order == 2)
        #expect(tags[1].title == "Test Title 3")
        #expect(tags[1].color == "#0000FF")

        #expect(tags[2].order == 3)
        #expect(tags[2].title == "Test Title 2")
        #expect(tags[2].color == "#00FF00")
        dependency.removeUserDefaults()
    }

    @Test
    func getTitleLineLimit() {
        let titleLineLimit = 3
        let dependency = Dependency()
        dependency.userDefaultsRepository.setTitleLineLimit(titleLineLimit)

        #expect(dependency.testTarget.getTitleLineLimit() == titleLineLimit)
        dependency.removeUserDefaults()
    }

    @Test
    func getTitleFontSize() {
        let titleFontSize = Float(16.0)
        let dependency = Dependency()
        dependency.userDefaultsRepository.setTitleFontSize(titleFontSize)

        #expect(dependency.testTarget.getTitleFontSize() == titleFontSize)
        dependency.removeUserDefaults()
    }

    @Test
    func getTitleLineSpacing() {
        let titleLineSpacing = Float.zero
        let dependency = Dependency()
        dependency.userDefaultsRepository.setTitleLineSpacing(titleLineSpacing)

        #expect(dependency.testTarget.getTitleLineSpacing() == titleLineSpacing)
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

extension TagsViewModelTests {
    struct Dependency {
        let testTarget: TagsViewModel
        let tagRepository: TagRepository
        private let userDefaults: UserDefaults
        let userDefaultsRepository: UserDefaultsRepository
        private static let suiteName: String = "Test"

        init() {
            tagRepository = TagRepository(modelContainer: ModelContainerManager(isStoredInMemoryOnly: true).modelContainer)
            guard let userDefaults = UserDefaults(suiteName: TagsViewModelTests.Dependency.suiteName) else {
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
            userDefaults.removePersistentDomain(forName: TagsViewModelTests.Dependency.suiteName)
        }
    }
}
