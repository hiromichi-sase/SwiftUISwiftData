//
//  EditMemoViewModel.swift
//  EditMemoViewModel
//
//  Created by Hiromichi Sase on 2026/05/04.
//

import Testing
@testable import SwiftUISwiftData

struct EditMemoViewModelTests {

    private let repository = MemoRepository(modelContainer: ModelContainerManager(isStoredInMemoryOnly: true).modelContainer)

    @Test func addMemo() async throws {
        let viewModel = await EditMemoViewModel(repository: repository)
        let memo = Memo(title: "Test Title", content: "Test Memo")
        try await viewModel.add(memo)

        guard let newMemo = await viewModel.repository.memos().first else {
            throw TestError(message: "Memo was not added to the repository.")
        }

        await #expect(viewModel.repository.memos().count == 1)
        #expect(newMemo.title == "Test Title")
        #expect(newMemo.content == "Test Memo")
        #expect(newMemo.createdAt == newMemo.updatedAt)
        #expect(newMemo.order == 1)
    }

    @Test func updateMemo() async throws {
        let viewModel = await EditMemoViewModel(repository: repository)
        let memo = Memo(title: "Test Title", content: "Test Memo")
        try await viewModel.add(memo)

        memo.title = "Updated Title"
        memo.content = "Updated Content"
        try await viewModel.update(memo)

        guard let newMemo = await viewModel.repository.memos().first else {
            throw TestError(message: "Memo was not added to the repository.")
        }

        #expect(newMemo.title == "Updated Title")
        #expect(newMemo.content == "Updated Content")
        #expect(newMemo.createdAt < newMemo.updatedAt)
    }

}
