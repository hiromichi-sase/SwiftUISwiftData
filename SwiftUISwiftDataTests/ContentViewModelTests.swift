//
//  ContentViewModelTests.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/04.
//

import Testing
@testable import SwiftUISwiftData

struct ContentViewModelTests {

    private let viewModel = ContentViewModel(
        memoRepository: MemoRepository(
            modelContainer: ModelContainerManager(isStoredInMemoryOnly: true).modelContainer
        ),
        userDefaultsRepository: UserDefaultsRepository(
            userDefaults: UserDefaultsRepository.test
        )
    )

    @Test func deleteMemos() async throws {
        let memo1 = Memo(title: "Test Title 1", content: "Test Memo 1", order: 1)
        let memo2 = Memo(title: "Test Title 2", content: "Test Memo 2", order: 2)
        let memo3 = Memo(title: "Test Title 3", content: "Test Memo 3", order: 3)

        try await viewModel.memoRepository.add(memo1)
        try await viewModel.memoRepository.add(memo2)
        try await viewModel.memoRepository.add(memo3)
        try await viewModel.delete([memo2])

        let memos = await viewModel.memoRepository.memos()
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

    @Test func moveMemo() async throws {
        let memo1 = Memo(title: "Test Title 1", content: "Test Memo 1", order: 1)
        let memo2 = Memo(title: "Test Title 2", content: "Test Memo 2", order: 2)
        let memo3 = Memo(title: "Test Title 3", content: "Test Memo 3", order: 3)

        try await viewModel.memoRepository.add(memo1)
        try await viewModel.memoRepository.add(memo2)
        try await viewModel.memoRepository.add(memo3)
        try await viewModel.moveMemo(from: [2], to: 1)

        let memos = await viewModel.memoRepository.memos()
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

}
