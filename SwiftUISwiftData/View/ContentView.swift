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

    @State
    var selectedSection: HomeView.Section?
    /// 編集モードの状態を管理する状態変数。
    @State
    var memosViewEditMode: EditMode = .inactive
    @State
    var selectedMemo: Memo?
    @State
    var tagsViewEditMode: EditMode = .inactive
    @State
    var selectedTag: Tag?
    /// メモの内容を編集するビューを開くかどうかのフラグ。
    @State
    var openEditMemoView: Bool = false

    var body: some View {
        NavigationSplitView {
            HomeView(section: $selectedSection)
        } content: {
            switch selectedSection {
                case .memosView:
                    MemosView(
                        editMode: $memosViewEditMode,
                        selectedMemo: $selectedMemo,
                        openEditMemoView: $openEditMemoView
                    )
                case .tagsView:
                    TagsView(
                        editMode: $tagsViewEditMode,
                        selectedTag: $selectedTag
                    )
                case .settingsView:
                    SettingsView()
                default:
                    EmptyView()
            }
        } detail: {
            switch selectedSection {
                case .memosView:
                    if memosViewEditMode.isEditing {
                        Text("Select memos to edit or delete")
                    }
                    else {
                        if let selectedMemo {
                            BrowseMemoView(memo: selectedMemo, openEditMemoView: openEditMemoView)
                                .modelContext(viewModel.modelContext)
                                .id(selectedMemo.id)
                        }
                        else {
                            Text("No memos selected")
                        }
                    }
                case .tagsView:
                    if tagsViewEditMode.isEditing {
                        Text("Select tags to edit or delete")
                    }
                    else {
                        if let selectedTag {
                            BrowseTagView(tag: selectedTag)
                                .modelContext(viewModel.modelContext)
                                .id(selectedTag.id)
                        }
                        else {
                            Text("No tags selected")
                        }
                    }
                case .settingsView:
                    EmptyView()
                default:
                    EmptyView()
            }
        }
    }
}

#Preview {
    ContentView()
}
