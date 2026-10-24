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
        memoRepository: MemoRepository(modelContext: ModelContainerManager.shared.modelContainer.mainContext)
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
    /// タグの内容を編集するビューを開くかどうかのフラグ。
    @State
    var openEditTagView: Bool = false

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
                        selectedTag: $selectedTag,
                        openEditTagView: $openEditTagView
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
                            BrowseTagView(tag: selectedTag, openEditTagView: openEditTagView)
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
        .onReceive(NotificationCenter.default.publisher(for: .openAddMemoFromShortcut)) { _ in
            openNewMemoFlowFromShortcut()
        }
        .onChange(of: selectedSection) { _, newValue in
            resetStateForSectionChange(newValue)
        }
    }
}

extension ContentView {
    func openNewMemoFlowFromShortcut() {
        resetNavigationState()

        selectedSection = .memosView

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            openEditMemoView = false
            DispatchQueue.main.async {
                openEditMemoView = true
            }
        }
    }

    func resetNavigationState() {
        clearMemoSelectionState()
        clearTagSelectionState()
        NotificationCenter.default.post(name: .closeAllPresentedViewsFromShortcut, object: nil)
    }

    func resetStateForSectionChange(_ section: HomeView.Section?) {
        if section != .memosView {
            clearMemoSelectionState()
        }

        if section != .tagsView {
            clearTagSelectionState()
        }
    }

    func clearMemoSelectionState() {
        memosViewEditMode = .inactive
        selectedMemo = nil
        openEditMemoView = false
    }

    func clearTagSelectionState() {
        tagsViewEditMode = .inactive
        selectedTag = nil
        openEditTagView = false
    }
}

#Preview {
    ContentView()
}
