//
//  EditMemoViewModelTests.swift
//  EditMemoViewModel
//
//  Created by Hiromichi Sase on 2026/05/04.
//

import Testing
@testable import SwiftUISwiftData
import Foundation

struct EditMemoViewModelTests {

    @Test func addMemo() async throws {
        let dependency = Dependency()
        let memo = Memo(title: "Test Title", content: "Test Memo")
        try await dependency.testTarget.add(memo)

        guard let newMemo = await dependency.memoRepository.memos().first else {
            throw TestError(message: "Memo was not added to the memoRepository.")
        }

        await #expect(dependency.memoRepository.memos().count == 1)
        #expect(newMemo.title == "Test Title")
        #expect(newMemo.content == "Test Memo")
        #expect(newMemo.createdAt == newMemo.updatedAt)
        #expect(newMemo.order == 1)
        dependency.removeUserDefaults()
    }

    @Test func updateMemo() async throws {
        let dependency = Dependency()
        let memo = Memo(title: "Test Title", content: "Test Memo")
        try await dependency.testTarget.add(memo)

        memo.title = "Updated Title"
        memo.content = "Updated Content"
        try await dependency.testTarget.update(memo)

        guard let newMemo = await dependency.memoRepository.memos().first else {
            throw TestError(message: "Memo was not added to the memoRepository.")
        }

        #expect(newMemo.title == "Updated Title")
        #expect(newMemo.content == "Updated Content")
        #expect(newMemo.createdAt < newMemo.updatedAt)
        dependency.removeUserDefaults()
    }

    @Test func getContentFontSize()  {
        let contentFontSize = Float(16.0)
        let dependency = Dependency()
        dependency.userDefaultsRepository.setContentFontSize(contentFontSize)

        #expect(dependency.testTarget.getContentFontSize() == contentFontSize)
        dependency.removeUserDefaults()
    }

    @Test func getContentLineSpacing()  {
        let contentLineSpacing = Float.zero
        let dependency = Dependency()
        dependency.userDefaultsRepository.setContentLineSpacing(contentLineSpacing)

        #expect(dependency.testTarget.getContentLineSpacing() == contentLineSpacing)
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
            userDefaults = UserDefaults(suiteName: EditMemoViewModelTests.Dependency.suiteName)!
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
