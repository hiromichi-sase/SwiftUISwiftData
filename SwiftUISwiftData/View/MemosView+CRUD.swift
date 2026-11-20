//
//  MemosView+CRUD.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/05.
//

import SwiftUI

extension MemosView {
    /// MemosView+Alert.swift から参照する削除対象。
    var selectedMemos: [Memo] {
        viewModel.selectedMemos()
    }

    func duplicateMemo(_ memo: Memo) {
        apply(viewModel.onDuplicateMemo(memo))
    }

    func deleteMemos(_ memos: [Memo]) {
        let output = viewModel.onDeleteMemos(
            memos,
            currentSelectedMemo: selectedMemo
        )

        selectedMemo = output.newSelectedMemo
        apply(output.result)
    }

    func moveMemo(from source: IndexSet, to destination: Int) {
        apply(
            viewModel.onMoveMemo(
                from: source,
                to: destination
            )
        )
    }

    func protect(_ memos: [Memo]) async {
        let result = await viewModel.onProtectMemos(memos)
        apply(result)
    }

    func unprotect(_ memos: [Memo]) async {
        let result = await viewModel.onUnprotectMemos(memos)
        apply(result)
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
                            userInfo: [
                                NSLocalizedDescriptionKey: message ?? "Unknown error."
                            ]
                        )
                        currentAlert = .error
                }
        }
    }
}

extension MemosViewModel {
    /// 編集モードで選択中のメモに保護されたメモが含まれるか。
    var containsProtectedSelectedMemo: Bool {
        selectedMemos().contains { $0.protected }
    }

    /// 親が保持する選択状態を基準に、一覧変更後の選択状態を返す。
    ///
    /// 既存の handleMemosChanged は ViewModel の selectedMemo を
    /// 使用するため、処理時に現在の選択値を渡す。
    func selectedMemoAfterMemosChanged(
        oldMemos: [Memo],
        newMemos: [Memo],
        editMode: EditMode,
        currentSelectedMemo: Memo?
    ) -> Memo? {
        selectedMemo = currentSelectedMemo

        handleMemosChanged(
            oldMemos: oldMemos,
            newMemos: newMemos,
            editMode: editMode
        )

        return selectedMemo
    }
}
