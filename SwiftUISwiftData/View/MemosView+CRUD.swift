//
//  MemosView+CRUD.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/05.
//

import SwiftUI

extension MemosView {
    var selectedMemos: [Memo] {
        viewModel.selectedMemos()
    }

    var filteredMemos: [Memo] {
        viewModel.filteredMemos
    }

    func duplicateMemo(_ memo: Memo) {
        do {
            try viewModel.duplicate(memo)
            toastMessage = "Successfully duplicated!"
        }
        catch {
            handleError(error, message: "Failed to duplicate memo: \(memo)")
        }
    }

    func deleteMemos(_ memos: [Memo]) {
        do {
            try viewModel.delete(memos)

            for memo in memos where viewModel.selectedMemo == memo {
                viewModel.selectedMemo = nil
            }

            viewModel.deselectAll()
            toastMessage = "Successfully deleted!"
        }
        catch {
            handleError(error, message: "Failed to delete memos: \(error)")
        }
    }

    func moveMemo(from source: IndexSet, to destination: Int) {
        let indices = source.map { $0 }
        do {
            try viewModel.moveMemo(from: indices, to: destination)
        }
        catch {
            handleError(error, message: "Failed to move memo: \(error)")
        }
    }

    func protect(_ memos: [Memo]) async {
        do {
            guard try await authenticate() else { return }
            try viewModel.protect(memos)
        }
        catch {
            handleError(error, message: "Failed to protect memos: \(error)")
        }
    }

    func unprotect(_ memos: [Memo]) async {
        do {
            guard try await authenticate() else { return }
            try viewModel.unprotect(memos)
        }
        catch {
            handleError(error, message: "Failed to unprotect memos: \(error)")
        }
    }

    private func authenticate() async throws -> Bool {
        let result = try await AuthenticationManager.shared.authenticate()
        guard result.success else {
            guard let error = result.error else {
                fatalError("Failed to get error from result.")
            }
            throw error
        }
        return result.success
    }

    private func handleError(_ error: any Error, message: String) {
        self.error = error
        currentAlert = .error
        print(message)
    }
}
