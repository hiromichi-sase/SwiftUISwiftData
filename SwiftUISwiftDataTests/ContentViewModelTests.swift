//
//  ContentViewModelTests.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/04.
//

import Foundation
import Testing

@testable import SwiftUISwiftData

struct ContentViewModelTests {
    @Test
    func filteredMemos() async throws {
        let dependency = Dependency()
        let memo1 = Memo(title: "Test Title 1", content: "Test Memo 1", order: 1)
        let memo2 = Memo(title: "Test Title 2", content: "Test Memo 2", order: 2)

        try await dependency.memoRepository.add(memo1)
        try await dependency.memoRepository.add(memo2)
        await dependency.testTarget.fetchMemos()

        let searchText: String = "1"
        let filteredMemos = await dependency.testTarget.filteredMemos(by: searchText)
        #expect(filteredMemos.count == 1)
        #expect(filteredMemos.first?.title == memo1.title)

        dependency.removeUserDefaults()
    }

    @Test
    func duplicate() async throws {
        let dependency = Dependency()
        let memo1 = Memo(title: "Test Title 1", content: "Test Memo 1", order: 1)
        let memo2 = Memo(title: "Test Title 2", content: "Test Memo 2", order: 2)

        try await dependency.memoRepository.add(memo1)
        try await dependency.memoRepository.add(memo2)

        let countBeforeDuplication = await dependency.memoRepository.memos().count
        try await dependency.testTarget.duplicate(memo1)

        let memos = await dependency.memoRepository.memos()
        #expect(memos.count == countBeforeDuplication + 1)

        #expect(memos[0].title == memo1.title)
        #expect(memos[0].content == memo1.content)
        #expect(memos[0].order == memo1.order)

        #expect(memos[1].title == memos[0].title)
        #expect(memos[1].content == memos[0].content)
        #expect(memos[1].order == memos[0].order + 1)

        #expect(memos[2].title == memo2.title)
        #expect(memos[2].content == memo2.content)
        #expect(memos[2].order == memos[1].order + 1)

        dependency.removeUserDefaults()
    }

    @Test
    func deleteMemos() async throws {
        let dependency = Dependency()
        let memo1 = Memo(title: "Test Title 1", content: "Test Memo 1", order: 1)
        let memo2 = Memo(title: "Test Title 2", content: "Test Memo 2", order: 2)
        let memo3 = Memo(title: "Test Title 3", content: "Test Memo 3", order: 3)

        try await dependency.memoRepository.add(memo1)
        try await dependency.memoRepository.add(memo2)
        try await dependency.memoRepository.add(memo3)
        try await dependency.testTarget.delete([memo2])

        let memos = await dependency.memoRepository.memos()
        if memos.count > 2 {
            throw TestError(message: "Expected only 2 memos after deletion, but found \(memos.count).")
        }

        #expect(memos[0].order == 1)
        #expect(memos[0].title == "Test Title 1")
        #expect(memos[0].content == "Test Memo 1")

        #expect(memos[1].order == 2)
        #expect(memos[1].title == "Test Title 3")
        #expect(memos[1].content == "Test Memo 3")
        dependency.removeUserDefaults()
    }

    @Test
    func moveMemo() async throws {
        let dependency = Dependency()
        let memo1 = Memo(title: "Test Title 1", content: "Test Memo 1", order: 1)
        let memo2 = Memo(title: "Test Title 2", content: "Test Memo 2", order: 2)
        let memo3 = Memo(title: "Test Title 3", content: "Test Memo 3", order: 3)

        try await dependency.memoRepository.add(memo1)
        try await dependency.memoRepository.add(memo2)
        try await dependency.memoRepository.add(memo3)
        try await dependency.testTarget.moveMemo(from: [2], to: 1)

        let memos = await dependency.memoRepository.memos()
        if memos.count != 3 {
            throw TestError(message: "Expected 3 memos after moving, but found \(memos.count).")
        }

        #expect(memos[0].order == 1)
        #expect(memos[0].title == "Test Title 1")
        #expect(memos[0].content == "Test Memo 1")

        #expect(memos[1].order == 2)
        #expect(memos[1].title == "Test Title 3")
        #expect(memos[1].content == "Test Memo 3")

        #expect(memos[2].order == 3)
        #expect(memos[2].title == "Test Title 2")
        #expect(memos[2].content == "Test Memo 2")
        dependency.removeUserDefaults()
    }

    @Test
    func protectMemos() async throws {
        let dependency = Dependency()
        let memo1 = Memo(title: "Test Title 1", content: "Test Memo 1", protected: false)
        let memo2 = Memo(title: "Test Title 2", content: "Test Memo 2", protected: false)
        let memo3 = Memo(title: "Test Title 3", content: "Test Memo 3", protected: false)

        try await dependency.memoRepository.add(memo1)
        try await dependency.memoRepository.add(memo2)
        try await dependency.memoRepository.add(memo3)

        try await dependency.testTarget.protect([memo1])
        try await dependency.testTarget.protect([memo2])
        try await dependency.testTarget.protect([memo3])

        let memos = await dependency.memoRepository.memos()
        for memo in memos {
            #expect(memo.protected)
        }

        dependency.removeUserDefaults()
    }

    @Test
    func unprotectMemos() async throws {
        let dependency = Dependency()
        let memo1 = Memo(title: "Test Title 1", content: "Test Memo 1", protected: true)
        let memo2 = Memo(title: "Test Title 2", content: "Test Memo 2", protected: true)
        let memo3 = Memo(title: "Test Title 3", content: "Test Memo 3", protected: true)

        try await dependency.memoRepository.add(memo1)
        try await dependency.memoRepository.add(memo2)
        try await dependency.memoRepository.add(memo3)

        try await dependency.testTarget.unprotect([memo1])
        try await dependency.testTarget.unprotect([memo2])
        try await dependency.testTarget.unprotect([memo3])

        let memos = await dependency.memoRepository.memos()
        for memo in memos {
            #expect(!memo.protected)
        }

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

extension ContentViewModelTests {
    struct Dependency {
        let testTarget: ContentViewModel
        let memoRepository: MemoRepository
        private let userDefaults: UserDefaults
        let userDefaultsRepository: UserDefaultsRepository
        private static let suiteName: String = "Test"

        init() {
            memoRepository = MemoRepository(modelContainer: ModelContainerManager(isStoredInMemoryOnly: true).modelContainer)
            guard let userDefaults = UserDefaults(suiteName: ContentViewModelTests.Dependency.suiteName) else {
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
            userDefaults.removePersistentDomain(forName: ContentViewModelTests.Dependency.suiteName)
        }
    }
}
