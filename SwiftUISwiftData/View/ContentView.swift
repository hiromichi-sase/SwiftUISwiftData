//
//  ContentView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/05/04.
//

import SwiftUI

/// メモ、タグ、設定のナビゲーションを表示するビュー。
struct ContentView: View {
    @State
    private var viewModel = ContentViewModel()

    var body: some View {
        NavigationSplitView {
            HomeView(viewModel: viewModel.homeViewModel)
        } content: {
            contentView
        } detail: {
            detailView
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .openAddMemoFromShortcut)
        ) { _ in
            viewModel.openNewMemoFlowFromShortcut()
        }
        .onChange(of: viewModel.homeViewModel.selectedSection) { _, newValue in
            viewModel.resetStateForSectionChange(newValue)
        }
        .onAppear {
            viewModel.resetStateForSectionChange(
                viewModel.homeViewModel.selectedSection
            )
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.homeViewModel.selectedSection {
            case .memos:
                MemosView(
                    editMode: $viewModel.state.memosViewEditMode,
                    selectedMemo: $viewModel.state.selectedMemo,
                    showingAddMemo: $viewModel.state.showingAddMemo
                )

            case .tags:
                TagsView(
                    editMode: $viewModel.state.tagsViewEditMode,
                    selectedTag: $viewModel.state.selectedTag
                )

            case .settings:
                SettingsView()

            case nil:
                EmptyView()
        }
    }

    @ViewBuilder
    private var detailView: some View {
        switch viewModel.homeViewModel.selectedSection {
            case .memos:
                memosDetailView

            case .tags:
                tagsDetailView

            case .settings, nil:
                EmptyView()
        }
    }

    @ViewBuilder
    private var memosDetailView: some View {
        if viewModel.state.memosViewEditMode.isEditing {
            Text("Select memos to edit or delete")
        }
        else if let selectedMemo = viewModel.state.selectedMemo {
            BrowseMemoView(memo: selectedMemo)
                .id(selectedMemo.id)
        }
        else {
            Text("No memos selected")
        }
    }

    @ViewBuilder
    private var tagsDetailView: some View {
        if viewModel.state.tagsViewEditMode.isEditing {
            Text("Select tags to edit or delete")
        }
        else if let selectedTag = viewModel.state.selectedTag {
            BrowseTagView(tag: selectedTag)
                .id(selectedTag.id)
        }
        else {
            Text("No tags selected")
        }
    }
}

#Preview {
    ContentView()
}
