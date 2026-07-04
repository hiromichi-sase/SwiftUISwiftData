//
//  ContentView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/05/04.
//

import SwiftData
import SwiftUI

/// メモのリストを表示するビュー。
struct ContentView: View {
    /// ビューの状態を管理するViewModel。
    @ObservedObject
    var viewModel = ContentViewModel(
        memoRepository: MemoRepository(modelContainer: ModelContainerManager.shared.modelContainer)
    )
    /// 編集モードの状態を管理する状態変数。
    @State
    var editMode: EditMode = .inactive
    @State
    var selectedMemo: Memo?
    /// メモの内容を編集するビューを開くかどうかのフラグ。
    @State
    var openEditMemoView: Bool = false

    var body: some View {
        NavigationSplitView {
            MemosView(
                editMode: $editMode,
                selectedMemo: $selectedMemo,
                openEditMemoView: $openEditMemoView
            )
        } detail: {
            if editMode == .inactive {
                if let selectedMemo {
                    BrowseMemoView(memo: selectedMemo, openEditMemoView: openEditMemoView)
                        .modelContext(viewModel.modelContext)
                        .id(selectedMemo.id)
                }
                else {
                    Text("No memos selected")
                }
            }
            else {
                Text("Select memos to edit or delete")
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(ModelContainerManager(isStoredInMemoryOnly: true).modelContainer)
}
