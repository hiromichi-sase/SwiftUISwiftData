//
//  TagsViewModelTests.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import Foundation
import SwiftData
import Testing

@testable import SwiftUISwiftData

struct TagsViewModelTests {
    @MainActor
    @Test
    func deleteTags() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let tag1 = Tag(title: "Test Title 1", color: "#FF0000", order: 1)
        let tag2 = Tag(title: "Test Title 2", color: "#00FF00", order: 2)
        let tag3 = Tag(title: "Test Title 3", color: "#0000FF", order: 3)

        try dependency.tagRepository.add(tag1)
        try dependency.tagRepository.add(tag2)
        try dependency.tagRepository.add(tag3)
        try dependency.testTarget.delete([tag2])

        let tags = try dependency.tagRepository.tags()
        #expect(tags.count == 2)

        #expect(tags[0].order == 1)
        #expect(tags[0].title == "Test Title 1")
        #expect(tags[0].color == "#FF0000")

        #expect(tags[1].order == 2)
        #expect(tags[1].title == "Test Title 3")
        #expect(tags[1].color == "#0000FF")
    }

    @MainActor
    @Test
    func moveTag() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let tag1 = Tag(title: "Test Title 1", color: "#FF0000", order: 1)
        let tag2 = Tag(title: "Test Title 2", color: "#00FF00", order: 2)
        let tag3 = Tag(title: "Test Title 3", color: "#0000FF", order: 3)

        try dependency.tagRepository.add(tag1)
        try dependency.tagRepository.add(tag2)
        try dependency.tagRepository.add(tag3)
        try dependency.testTarget.moveTag(from: [2], to: 1)

        let tags = try dependency.tagRepository.tags()
        #expect(tags.count == 3)

        #expect(tags[0].order == 1)
        #expect(tags[0].title == "Test Title 1")
        #expect(tags[0].color == "#FF0000")

        #expect(tags[1].order == 2)
        #expect(tags[1].title == "Test Title 3")
        #expect(tags[1].color == "#0000FF")

        #expect(tags[2].order == 3)
        #expect(tags[2].title == "Test Title 2")
        #expect(tags[2].color == "#00FF00")
    }

    @MainActor
    @Test
    func getTitleLineLimit() throws {
        let titleLineLimit = 3
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }
        dependency.userDefaultsRepository.setTitleLineLimit(titleLineLimit)

        #expect(dependency.testTarget.getTitleLineLimit() == titleLineLimit)
    }

    @MainActor
    @Test
    func getTitleFontSize() throws {
        let titleFontSize = Float(16.0)
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }
        dependency.userDefaultsRepository.setTitleFontSize(titleFontSize)

        #expect(dependency.testTarget.getTitleFontSize() == titleFontSize)
    }

    @MainActor
    @Test
    func getTitleLineSpacing() throws {
        let titleLineSpacing = Float.zero
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }
        dependency.userDefaultsRepository.setTitleLineSpacing(titleLineSpacing)

        #expect(dependency.testTarget.getTitleLineSpacing() == titleLineSpacing)
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
}

extension TagsViewModelTests {
    struct Dependency {
        private let container: ModelContainer
        let testTarget: TagsViewModel
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
            tagRepository = TagRepository(modelContext: container.mainContext)
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
