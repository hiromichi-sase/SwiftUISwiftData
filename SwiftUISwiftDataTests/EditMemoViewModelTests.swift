//
//  EditMemoViewModelTests.swift
//  EditMemoViewModel
//
//  Created by Hiromichi Sase on 2026/05/04.
//

import Foundation
import Testing

@testable import SwiftUISwiftData

struct EditMemoViewModelTests {
    @Test
    func addMemo() async throws {
        let dependency = Dependency()
        let addedTitle = "Added Title"
        let addedContent = "Added Content"
        let addedTags = [Tag(title: "Added Tag", color: "#000000", createdAt: Date(), updatedAt: Date(), order: .zero)]
        let memo = Memo(title: addedTitle, content: addedContent, tags: addedTags)
        try await dependency.testTarget.add(memo)

        guard let newMemo = await dependency.memoRepository.memos().first else {
            throw TestError(message: "Memo was not added to the memoRepository.")
        }

        await #expect(dependency.memoRepository.memos().count == 1)
        #expect(newMemo.title == addedTitle)
        #expect(newMemo.content == addedContent)
        #expect(newMemo.tags == addedTags)
        #expect(newMemo.createdAt == newMemo.updatedAt)
        #expect(newMemo.order == 1)
        dependency.removeUserDefaults()
    }

    @Test
    func updateMemo() async throws {
        let dependency = Dependency()
        let memo = Memo(title: "Test Title", content: "Test Memo")
        try await dependency.testTarget.add(memo)

        let updatedTitle = "Updated Title"
        let updatedContent = "Updated Content"
        let updateTags = [Tag(title: "Updated Tag 1", color: "#000000", createdAt: Date(), updatedAt: Date(), order: .zero)]
        try await dependency.testTarget.update(memo, title: updatedTitle, content: updatedContent, tags: updateTags)

        guard let newMemo = await dependency.memoRepository.memos().first else {
            throw TestError(message: "Memo was not added to the memoRepository.")
        }

        #expect(newMemo.title == updatedTitle)
        #expect(newMemo.content == updatedContent)
        #expect(newMemo.tags == updateTags)
        #expect(newMemo.createdAt < newMemo.updatedAt)
        dependency.removeUserDefaults()
    }

    @Test
    func getContentFontSize() {
        let contentFontSize = Float(16.0)
        let dependency = Dependency()
        dependency.userDefaultsRepository.setContentFontSize(contentFontSize)

        #expect(dependency.testTarget.getContentFontSize() == contentFontSize)
        dependency.removeUserDefaults()
    }

    @Test
    func getContentLineSpacing() {
        let contentLineSpacing = Float.zero
        let dependency = Dependency()
        dependency.userDefaultsRepository.setContentLineSpacing(contentLineSpacing)

        #expect(dependency.testTarget.getContentLineSpacing() == contentLineSpacing)
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

extension EditMemoViewModelTests {
    struct Dependency {
        let testTarget: EditMemoViewModel
        let memoRepository: MemoRepository
        let tagRepository: TagRepository
        private let userDefaults: UserDefaults
        let userDefaultsRepository: UserDefaultsRepository
        private static let suiteName: String = "Test"

        init() {
            memoRepository = .init(modelContainer: ModelContainerManager(isStoredInMemoryOnly: true).modelContainer)
            tagRepository = .init(modelContainer: ModelContainerManager(isStoredInMemoryOnly: true).modelContainer)
            guard let userDefaults = UserDefaults(suiteName: EditMemoViewModelTests.Dependency.suiteName) else {
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
            userDefaults.removePersistentDomain(forName: EditMemoViewModelTests.Dependency.suiteName)
        }
    }
}
