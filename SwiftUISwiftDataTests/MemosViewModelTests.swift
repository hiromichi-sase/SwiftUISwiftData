//
//  MemosViewModelTests.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/04.
//

import Foundation
import SwiftData
import Testing

@testable import SwiftUISwiftData

struct MemosViewModelTests {
    @MainActor
    @Test
    func filteredMemos() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let context = dependency.memoRepository.modelContext
        let tag1 = Tag(title: "Test Tag 1", color: "#000000")
        context.insert(tag1)

        let memo1 = Memo(title: "Test Title 1", content: "Test Memo 1", order: 1, tags: [tag1])
        let memo2 = Memo(title: "Test Title 2", content: "Test Memo 2", order: 2, tags: [tag1])

        try dependency.memoRepository.add(memo1)
        try dependency.memoRepository.add(memo2)

        let testTarget = dependency.makeTestTarget()
        let filteredMemos = testTarget.filteredMemos(by: "Title 1", and: [tag1])
        #expect(filteredMemos.count == 2)
    }

    @MainActor
    @Test
    func filteredMemos_noFilter() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let context = dependency.memoRepository.modelContext
        let tag1 = Tag(title: "Test Tag 1", color: "#000000")
        context.insert(tag1)

        let memo1 = Memo(title: "Test Title 1", content: "Test Memo 1", order: 1, tags: [tag1])
        let memo2 = Memo(title: "Test Title 2", content: "Test Memo 2", order: 2, tags: [tag1])

        try dependency.memoRepository.add(memo1)
        try dependency.memoRepository.add(memo2)

        let testTarget = dependency.makeTestTarget()
        let filteredMemos = testTarget.filteredMemos(by: "", and: [])
        #expect(filteredMemos.count == 2)
    }

    @MainActor
    @Test
    func duplicate() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let memo1 = Memo(title: "Test Title 1", content: "Test Memo 1", order: 1)
        let memo2 = Memo(title: "Test Title 2", content: "Test Memo 2", order: 2)

        try dependency.memoRepository.add(memo1)
        try dependency.memoRepository.add(memo2)

        let testTarget = dependency.makeTestTarget()
        let countBeforeDuplication = try dependency.memoRepository.memos().count
        try testTarget.duplicate(memo1)

        let memos = try dependency.memoRepository.memos()
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
    }

    @MainActor
    @Test
    func deleteMemos() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let memo1 = Memo(title: "Test Title 1", content: "Test Memo 1", order: 1)
        let memo2 = Memo(title: "Test Title 2", content: "Test Memo 2", order: 2)
        let memo3 = Memo(title: "Test Title 3", content: "Test Memo 3", order: 3)

        try dependency.memoRepository.add(memo1)
        try dependency.memoRepository.add(memo2)
        try dependency.memoRepository.add(memo3)

        let testTarget = dependency.makeTestTarget()
        try testTarget.delete([memo2])

        let memos = try dependency.memoRepository.memos()
        if memos.count > 2 {
            throw TestError(message: "Expected only 2 memos after deletion, but found \(memos.count).")
        }

        #expect(memos[0].order == 1)
        #expect(memos[0].title == "Test Title 1")
        #expect(memos[0].content == "Test Memo 1")
        #expect(memos[1].order == 2)
        #expect(memos[1].title == "Test Title 3")
        #expect(memos[1].content == "Test Memo 3")
    }

    @MainActor
    @Test
    func moveMemo() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let memo1 = Memo(title: "Test Title 1", content: "Test Memo 1", order: 1)
        let memo2 = Memo(title: "Test Title 2", content: "Test Memo 2", order: 2)
        let memo3 = Memo(title: "Test Title 3", content: "Test Memo 3", order: 3)

        try dependency.memoRepository.add(memo1)
        try dependency.memoRepository.add(memo2)
        try dependency.memoRepository.add(memo3)

        let testTarget = dependency.makeTestTarget()
        try testTarget.moveMemo(from: [2], to: 1)

        let memos = try dependency.memoRepository.memos()
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
    }

    @MainActor
    @Test
    func protectMemos() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let memo1 = Memo(title: "Test Title 1", content: "Test Memo 1", protected: false)
        let memo2 = Memo(title: "Test Title 2", content: "Test Memo 2", protected: false)
        let memo3 = Memo(title: "Test Title 3", content: "Test Memo 3", protected: false)

        try dependency.memoRepository.add(memo1)
        try dependency.memoRepository.add(memo2)
        try dependency.memoRepository.add(memo3)

        let testTarget = dependency.makeTestTarget()
        try testTarget.protect([memo1])
        try testTarget.protect([memo2])
        try testTarget.protect([memo3])

        let memos = try dependency.memoRepository.memos()
        for memo in memos {
            #expect(memo.protected)
        }
    }

    @MainActor
    @Test
    func unprotectMemos() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let memo1 = Memo(title: "Test Title 1", content: "Test Memo 1", protected: true)
        let memo2 = Memo(title: "Test Title 2", content: "Test Memo 2", protected: true)
        let memo3 = Memo(title: "Test Title 3", content: "Test Memo 3", protected: true)

        try dependency.memoRepository.add(memo1)
        try dependency.memoRepository.add(memo2)
        try dependency.memoRepository.add(memo3)

        let testTarget = dependency.makeTestTarget()
        try testTarget.unprotect([memo1])
        try testTarget.unprotect([memo2])
        try testTarget.unprotect([memo3])

        let memos = try dependency.memoRepository.memos()
        for memo in memos {
            #expect(!memo.protected)
        }
    }

    @MainActor
    @Test
    func getTitleLineLimit() throws {
        let titleLineLimit = 3
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setTitleLineLimit(titleLineLimit)
        let testTarget = dependency.makeTestTarget()
        #expect(testTarget.getTitleLineLimit() == titleLineLimit)
    }

    @MainActor
    @Test
    func getTitleFontSize() throws {
        let titleFontSize = Float(16.0)
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setTitleFontSize(titleFontSize)
        let testTarget = dependency.makeTestTarget()
        #expect(testTarget.getTitleFontSize() == titleFontSize)
    }

    @MainActor
    @Test
    func getTitleLineSpacing() throws {
        let titleLineSpacing = Float.zero
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setTitleLineSpacing(titleLineSpacing)
        let testTarget = dependency.makeTestTarget()
        #expect(testTarget.getTitleLineSpacing() == titleLineSpacing)
    }

    @MainActor
    @Test
    func getShowInfo() throws {
        let hasLink = false
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setShowInfo(hasLink)
        let testTarget = dependency.makeTestTarget()
        #expect(testTarget.getShowInfo() == hasLink)
    }
}

extension MemosViewModelTests {
    struct Dependency {
        private let container: ModelContainer
        let memoRepository: MemoRepository
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
            memoRepository = MemoRepository(modelContext: container.mainContext)

            guard let userDefaults = UserDefaults(suiteName: suiteName) else {
                fatalError("Could not create UserDefaults")
            }

            self.userDefaults = userDefaults
            userDefaultsRepository = .init(userDefaults: userDefaults)
        }

        @MainActor
        func makeTestTarget() -> MemosViewModel {
            .init(
                memoRepository: memoRepository,
                userDefaultsRepository: userDefaultsRepository
            )
        }

        func removeUserDefaults() {
            userDefaults.removePersistentDomain(forName: suiteName)
        }
    }
}
