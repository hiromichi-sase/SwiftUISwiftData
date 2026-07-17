//
//  TagsView+CRUD.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import SwiftUI

extension TagsView {
    /// 選択されたタグの配列を返す計算プロパティ。
    var selectedTags: [Tag] {
        viewModel.tags.filter { selection.contains($0.id) }
    }

    /// 指定されたタグを削除する関数。
    ///
    /// 削除後に選択状態を更新し、すべてのタグの順序を再計算して保存する。
    /// - Parameter tags: 削除するタグの配列
    func deleteTags(_ tags: [Tag]) {
        do {
            try viewModel.delete(tags)

            for tag in tags where selectedTag == tag {
                selectedTag = nil
            }

            selection.removeAll()
            toastMessage = "Successfully deleted!"
        }
        catch {
            self.error = error
            currentAlert = .error
            print("Failed to delete tags: \(error)")
        }
    }

    /// 指定されたタグを新しい位置に移動する関数。
    ///
    /// 移動後にすべてのタグの順序を再計算して保存する。
    /// - Parameters:
    ///   - source: 移動するタグのインデックス
    ///   - destination: 移動先のインデックス
    func moveTag(from source: IndexSet, to destination: Int) {
        let indices = source.map { $0 }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                try viewModel.moveTag(from: indices, to: destination)
            }
            catch {
                self.error = error
                currentAlert = .error
                print("Failed to move tag: \(error)")
            }
        }
    }
}
