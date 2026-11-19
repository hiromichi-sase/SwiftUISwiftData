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
        apply(viewModel.onDuplicateMemo(memo))
    }

    func deleteMemos(_ memos: [Memo]) {
        let output = viewModel.onDeleteMemos(memos, currentSelectedMemo: selectedMemo)
        selectedMemo = output.newSelectedMemo
        apply(output.result)
    }

    func moveMemo(from source: IndexSet, to destination: Int) {
        apply(viewModel.onMoveMemo(from: source, to: destination))
    }

    func protect(_ memos: [Memo]) async {
        apply(await viewModel.onProtectMemos(memos))
    }

    func unprotect(_ memos: [Memo]) async {
        apply(await viewModel.onUnprotectMemos(memos))
    }

    private func apply(_ result: MemosViewModel.ActionResult) {
        switch result {
            case .none:
                break

            case .toast(let message):
                toastMessage = message

            case .alert(let alert, let message):
                switch alert {
                    case .error:
                        error = NSError(
                            domain: "MemosView",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: message ?? "Unknown error."]
                        )
                        currentAlert = .error
                }
        }
    }
}
