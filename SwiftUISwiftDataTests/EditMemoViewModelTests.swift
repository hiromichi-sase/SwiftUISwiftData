//
//  EditMemoViewModelTests.swift
//  EditMemoViewModel
//
//  Created by Hiromichi Sase on 2026/05/04.
//

import Foundation
import SwiftData
import Testing

@testable import SwiftUISwiftData

struct EditMemoViewModelTests {
    @MainActor
    @Test
    func addMemo() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let context = dependency.memoRepository.modelContext
        let addedTitle = "Added Title"
        let addedContent = "Added Content"
        let addedTag = SwiftUISwiftData.Tag(
            title: "Added Tag",
            color: "#000000",
            createdAt: Date(),
            updatedAt: Date(),
            order: .zero
        )
        context.insert(addedTag)

        let memo = Memo(title: addedTitle, content: addedContent, tags: [addedTag])
        try dependency.testTarget.add(memo)

        let memos = try dependency.memoRepository.memos()
        guard let newMemo = memos.first else {
            throw TestError(message: "Memo was not added to the memoRepository.")
        }

        #expect(memos.count == 1)
        #expect(newMemo.title == addedTitle)
        #expect(newMemo.content == addedContent)
        #expect(newMemo.tags == [addedTag])
        #expect(newMemo.createdAt == newMemo.updatedAt)
        #expect(newMemo.order == 1)
    }

    @MainActor
    @Test
    func updateMemo() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let context = dependency.memoRepository.modelContext
        let memo = Memo(title: "Test Title", content: "Test Memo")
        try dependency.testTarget.add(memo)

        let updatedTitle = "Updated Title"
        let updatedContent = "Updated Content"
        let updatedTag = SwiftUISwiftData.Tag(
            title: "Updated Tag 1",
            color: "#000000",
            createdAt: Date(),
            updatedAt: Date(),
            order: .zero
        )
        context.insert(updatedTag)

        try dependency.testTarget.update(memo, title: updatedTitle, content: updatedContent, tags: [updatedTag])

        let memos = try dependency.memoRepository.memos()
        guard let newMemo = memos.first else {
            throw TestError(message: "Memo was not added to the memoRepository.")
        }

        #expect(newMemo.title == updatedTitle)
        #expect(newMemo.content == updatedContent)
        #expect(newMemo.tags == [updatedTag])
        #expect(newMemo.createdAt < newMemo.updatedAt)
    }

    @MainActor
    @Test
    func getContentFontSize() throws {
        let contentFontSize = Float(16.0)
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }
        dependency.userDefaultsRepository.setContentFontSize(contentFontSize)

        #expect(dependency.testTarget.getContentFontSize() == contentFontSize)
    }

    @MainActor
    @Test
    func getContentLineSpacing() throws {
        let contentLineSpacing = Float.zero
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }
        dependency.userDefaultsRepository.setContentLineSpacing(contentLineSpacing)

        #expect(dependency.testTarget.getContentLineSpacing() == contentLineSpacing)
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

extension EditMemoViewModelTests {
    struct Dependency {
        private let container: ModelContainer
        let testTarget: EditMemoViewModel
        let memoRepository: MemoRepository
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

            memoRepository = .init(modelContext: container.mainContext)
            tagRepository = .init(modelContext: container.mainContext)

            guard let userDefaults = UserDefaults(suiteName: suiteName) else {
                fatalError("Could not create UserDefaults")
            }
            self.userDefaults = userDefaults
            userDefaultsRepository = .init(userDefaults: userDefaults)

            testTarget = .init(
                memoRepository: memoRepository,
                tagRepository: tagRepository,
                userDefaultsRepository: userDefaultsRepository
            )
        }

        func removeUserDefaults() {
            userDefaults.removePersistentDomain(forName: suiteName)
        }
    }
}
