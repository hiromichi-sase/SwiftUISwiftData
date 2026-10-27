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

        let tag1 = Tag(title: "Test Tag 1", color: "#000000")
        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            tags: [tag1],
            memos: [
                Memo(title: "Test Title 1", content: "Test Memo 1", order: 1, tags: [tag1]),
                Memo(title: "Test Title 2", content: "Test Memo 2", order: 2, tags: [tag1]),
            ]
        )

        let testTarget = dependency.makeTestTarget()
        let filteredMemos = testTarget.filteredMemos(by: "Title 1", and: [tag1])
        #expect(filteredMemos.count == 2)
    }

    @MainActor
    @Test
    func filteredMemos_noFilter() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let tag1 = Tag(title: "Test Tag 1", color: "#000000")
        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            tags: [tag1],
            memos: [
                Memo(title: "Test Title 1", content: "Test Memo 1", order: 1, tags: [tag1]),
                Memo(title: "Test Title 2", content: "Test Memo 2", order: 2, tags: [tag1]),
            ]
        )

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
        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            memos: [memo1, memo2]
        )

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
        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            memos: [memo1, memo2, memo3]
        )

        let testTarget = dependency.makeTestTarget()
        try testTarget.delete([memo2])

        let memos = try dependency.memoRepository.memos()
        #expect(memos.count == 2)
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
        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            memos: [memo1, memo2, memo3]
        )

        let testTarget = dependency.makeTestTarget()
        try testTarget.moveMemo(from: [2], to: 1)

        let memos = try dependency.memoRepository.memos()
        #expect(memos.count == 3)
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

        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "Test Title 1", content: "Test Memo 1", protected: false),
                Memo(title: "Test Title 2", content: "Test Memo 2", protected: false),
                Memo(title: "Test Title 3", content: "Test Memo 3", protected: false),
            ]
        )

        let testTarget = dependency.makeTestTarget()
        let memosBefore = try dependency.memoRepository.memos()
        try testTarget.protect([memosBefore[0]])
        try testTarget.protect([memosBefore[1]])
        try testTarget.protect([memosBefore[2]])

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

        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "Test Title 1", content: "Test Memo 1", protected: true),
                Memo(title: "Test Title 2", content: "Test Memo 2", protected: true),
                Memo(title: "Test Title 3", content: "Test Memo 3", protected: true),
            ]
        )

        let testTarget = dependency.makeTestTarget()
        let memosBefore = try dependency.memoRepository.memos()
        try testTarget.unprotect([memosBefore[0]])
        try testTarget.unprotect([memosBefore[1]])
        try testTarget.unprotect([memosBefore[2]])

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

    @MainActor
    private func seed(
        memoRepository: MemoRepository,
        context: ModelContext,
        tags: [Tag] = [],
        memos: [Memo]
    ) throws {
        for tag in tags {
            context.insert(tag)
        }
        for memo in memos {
            try memoRepository.add(memo)
        }
    }
}

extension MemosViewModelTests {
    struct Dependency {
        private let container: ModelContainer
        let testTarget: MemosViewModel
        let memoRepository: MemoRepository
        let userDefaultsRepository: UserDefaultsRepository
        private let support: TestDependencySupport

        @MainActor
        init() throws {
            let support = TestDependencySupport()
            self.support = support
            userDefaultsRepository = support.userDefaultsRepository

            container = try ModelContainer(
                for: Memo.self,
                Tag.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )

            memoRepository = MemoRepository(modelContext: container.mainContext)

            testTarget = .init(
                memoRepository: memoRepository,
                userDefaultsRepository: userDefaultsRepository
            )
        }

        @MainActor
        func makeTestTarget() -> MemosViewModel {
            .init(
                memoRepository: memoRepository,
                userDefaultsRepository: userDefaultsRepository
            )
        }

        func removeUserDefaults() {
            support.removeUserDefaults()
        }
    }
}
