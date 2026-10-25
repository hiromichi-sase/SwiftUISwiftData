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
    /// 新しいメモを追加するためのフルスクリーンカバーを表示するフラグ。
    @State
    var showingAddMemo: Bool = false

    var body: some View {
        NavigationSplitView {
            HomeView(section: $selectedSection)
        } content: {
            switch selectedSection {
                case .memosView:
                    MemosView(
                        editMode: $memosViewEditMode,
                        selectedMemo: $selectedMemo,
                        showingAddMemo: $showingAddMemo,
                    )
                case .tagsView:
                    TagsView(
                        editMode: $tagsViewEditMode,
                        selectedTag: $selectedTag,
                    )
                case .settingsView:
                    SettingsView()
                default:
                    EmptyView()
            }
        } detail: {
            detailView
        }
        .onReceive(NotificationCenter.default.publisher(for: .openAddMemoFromShortcut)) { _ in
            openNewMemoFlowFromShortcut()
        }
        .onChange(of: selectedSection) { _, newValue in
            resetStateForSectionChange(newValue)
        }
    }

    @ViewBuilder
    private var detailView: some View {
        switch selectedSection {
            case .memosView:
                memosDetailView
            case .tagsView:
                tagsDetailView
            case .settingsView:
                EmptyView()
            default:
                EmptyView()
        }
    }

    @ViewBuilder
    private var memosDetailView: some View {
        if memosViewEditMode.isEditing {
            Text("Select memos to edit or delete")
        }
        else if let selectedMemo {
            BrowseMemoView(memo: selectedMemo)
                .modelContext(viewModel.modelContext)
                .id(selectedMemo.id)
        }
        else {
            Text("No memos selected")
        }
    }

    @ViewBuilder
    private var tagsDetailView: some View {
        if tagsViewEditMode.isEditing {
            Text("Select tags to edit or delete")
        }
        else if let selectedTag {
            BrowseTagView(tag: selectedTag)
                .modelContext(viewModel.modelContext)
                .id(selectedTag.id)
        }
        else {
            Text("No tags selected")
        }
    }
}

extension ContentView {
    func openNewMemoFlowFromShortcut() {
        resetNavigationState()

        selectedSection = .memosView
        showingAddMemo = true
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
    }

    func clearTagSelectionState() {
        tagsViewEditMode = .inactive
        selectedTag = nil
    }
}

#Preview {
    ContentView()
}
