//
//  ContentViewModelTests.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/04.
//

import Testing
@testable import SwiftUISwiftData
import Foundation

struct ContentViewModelTests {

    @Test func deleteMemos() async throws {
        let dependency = Dependency()
        let memo1 = Memo(title: "Test Title 1", content: "Test Memo 1", order: 1)
        let memo2 = Memo(title: "Test Title 2", content: "Test Memo 2", order: 2)
        let memo3 = Memo(title: "Test Title 3", content: "Test Memo 3", order: 3)

        try await dependency.testTarget.memoRepository.add(memo1)
        try await dependency.testTarget.memoRepository.add(memo2)
        try await dependency.testTarget.memoRepository.add(memo3)
        try await dependency.testTarget.delete([memo2])

        let memos = await dependency.testTarget.memoRepository.memos()
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

    @Test func moveMemo() async throws {
        let dependency = Dependency()
        let memo1 = Memo(title: "Test Title 1", content: "Test Memo 1", order: 1)
        let memo2 = Memo(title: "Test Title 2", content: "Test Memo 2", order: 2)
        let memo3 = Memo(title: "Test Title 3", content: "Test Memo 3", order: 3)

        try await dependency.testTarget.memoRepository.add(memo1)
        try await dependency.testTarget.memoRepository.add(memo2)
        try await dependency.testTarget.memoRepository.add(memo3)
        try await dependency.testTarget.moveMemo(from: [2], to: 1)

        let memos = await dependency.testTarget.memoRepository.memos()
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

    @Test func getTitleLineLimit()  {
        let titleLineLimit = 3
        let dependency = Dependency()
        dependency.testTarget.userDefaultsRepository.setTitleLineLimit(titleLineLimit)

        #expect(dependency.testTarget.getTitleLineLimit() == titleLineLimit)
        dependency.removeUserDefaults()
    }

    @Test func getTitleFontSize()  {
        let titleFontSize = Float(16.0)
        let dependency = Dependency()
        dependency.testTarget.userDefaultsRepository.setTitleFontSize(titleFontSize)

        #expect(dependency.testTarget.getTitleFontSize() == titleFontSize)
        dependency.removeUserDefaults()
    }

    @Test func getTitleLineSpacing()  {
        let titleLineSpacing = Float.zero
        let dependency = Dependency()
        dependency.testTarget.userDefaultsRepository.setTitleLineSpacing(titleLineSpacing)

        #expect(dependency.testTarget.getTitleLineSpacing() == titleLineSpacing)
        dependency.removeUserDefaults()
    }

}

extension ContentViewModelTests {
    struct Dependency {
        let testTarget: ContentViewModel
        let userDefaults: UserDefaults
        static let suiteName: String = "Test"

        init() {
            userDefaults = UserDefaults(suiteName: ContentViewModelTests.Dependency.suiteName)!
            testTarget = .init(
                memoRepository: MemoRepository(modelContainer: ModelContainerManager(isStoredInMemoryOnly: true).modelContainer),
                userDefaultsRepository: .init(userDefaults: userDefaults)
            )
        }

        func removeUserDefaults() {
            userDefaults.removePersistentDomain(forName: ContentViewModelTests.Dependency.suiteName)
        }
    }
}
