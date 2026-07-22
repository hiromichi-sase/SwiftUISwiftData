//
//  MemosView+CRUD.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/05.
//

import SwiftUI

extension MemosView {
    /// 選択されたメモの配列を返す計算プロパティ。
    var selectedMemos: [Memo] {
        viewModel.memos.filter { selection.contains($0.id) }
    }

    var filteredMemos: [Memo] {
        viewModel.filteredMemos(
            by: searchText,
            and: tagsForFiltering,
        )
    }

    func duplicateMemo(_ memo: Memo) {
        do {
            memoDuplicateSource = memo
            try viewModel.duplicate(memo)
            toastMessage = "Successfully duplicated!"
        }
        catch {
            memoDuplicateSource = nil
            self.error = error
            currentAlert = .error
            print("Failed to duplicate memo: \(memo)")
        }
    }

    /// 指定されたメモを削除する関数。
    ///
    /// 削除後に選択状態を更新し、すべてのメモの順序を再計算して保存する。
    /// - Parameter memos: 削除するメモの配列
    func deleteMemos(_ memos: [Memo]) {
        do {
            try viewModel.delete(memos)

            for memo in memos where selectedMemo == memo {
                selectedMemo = nil
            }

            selection.removeAll()
            toastMessage = "Successfully deleted!"
        }
        catch {
            self.error = error
            currentAlert = .error
            print("Failed to delete memos: \(error)")
        }
    }

    /// 指定されたメモを新しい位置に移動する関数。
    ///
    /// 移動後にすべてのメモの順序を再計算して保存する。
    /// - Parameters:
    ///   - source: 移動するメモのインデックス
    ///   - destination: 移動先のインデックス
    func moveMemo(from source: IndexSet, to destination: Int) {
        let indices = source.map { $0 }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                try viewModel.moveMemo(from: indices, to: destination)
            }
            catch {
                self.error = error
                currentAlert = .error
                print("Failed to move memo: \(error)")
            }
        }
    }

    func protect(_ memos: [Memo]) async {
        do {
            guard try await authenticate() else { return }
            try viewModel.protect(memos)
        }
        catch {
            self.error = error
            currentAlert = .error
            print("Failed to protect memos: \(error)")
        }
    }

    func unprotect(_ memos: [Memo]) async {
        do {
            guard try await authenticate() else { return }
            try viewModel.unprotect(memos)
        }
        catch {
            self.error = error
            currentAlert = .error
            print("Failed to unprotect memos: \(error)")
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
}
