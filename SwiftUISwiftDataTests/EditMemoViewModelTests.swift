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
        let memo = Memo(title: addedTitle, content: addedContent)
        try await dependency.testTarget.add(memo)

        guard let newMemo = await dependency.memoRepository.memos().first else {
            throw TestError(message: "Memo was not added to the memoRepository.")
        }

        await #expect(dependency.memoRepository.memos().count == 1)
        #expect(newMemo.title == addedTitle)
        #expect(newMemo.content == addedContent)
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
        try await dependency.testTarget.update(memo, title: updatedTitle, content: updatedContent)

        guard let newMemo = await dependency.memoRepository.memos().first else {
            throw TestError(message: "Memo was not added to the memoRepository.")
        }

        #expect(newMemo.title == updatedTitle)
        #expect(newMemo.content == updatedContent)
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
    func getShowDate() {
        let hasLink = false
        let dependency = Dependency()
        dependency.userDefaultsRepository.setShowDate(hasLink)

        #expect(dependency.testTarget.getShowDate() == hasLink)
        dependency.removeUserDefaults()
    }
}

extension EditMemoViewModelTests {
    struct Dependency {
        let testTarget: EditMemoViewModel
        let memoRepository: MemoRepository
        private let userDefaults: UserDefaults
        let userDefaultsRepository: UserDefaultsRepository
        private static let suiteName: String = "Test"

        init() {
            memoRepository = .init(modelContainer: ModelContainerManager(isStoredInMemoryOnly: true).modelContainer)
            guard let userDefaults = UserDefaults(suiteName: EditMemoViewModelTests.Dependency.suiteName) else {
                fatalError("Could not create UserDefaults")
            }
            self.userDefaults = userDefaults
            userDefaultsRepository = .init(userDefaults: userDefaults)
            testTarget = .init(
                memoRepository: memoRepository,
                userDefaultsRepository: userDefaultsRepository
            )
        }

        func removeUserDefaults() {
            userDefaults.removePersistentDomain(forName: EditMemoViewModelTests.Dependency.suiteName)
        }
    }
}
