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
    @State
    private var viewModel = ContentViewModel(
        memoRepository: MemoRepository(modelContext: ModelContainerManager.shared.modelContainer.mainContext)
    )

    @State
    private var homeViewModel = HomeViewModel(selectedSection: nil)

    var body: some View {
        NavigationSplitView {
            HomeView(viewModel: homeViewModel)
        } content: {
            switch homeViewModel.selectedSection {
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
                default:
                    EmptyView()
            }
        } detail: {
            detailView
        }
        .onReceive(NotificationCenter.default.publisher(for: .openAddMemoFromShortcut)) { _ in
            openNewMemoFlowFromShortcut()
        }
        .onChange(of: homeViewModel.selectedSection) { _, newValue in
            resetStateForSectionChange(newValue)
        }
        .onAppear {
            viewModel.resetStateForSectionChange(homeViewModel.selectedSection)
        }
    }

    @ViewBuilder
    private var detailView: some View {
        switch homeViewModel.selectedSection {
            case .memos:
                memosDetailView
            case .tags:
                tagsDetailView
            case .settings:
                EmptyView()
            default:
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
                .modelContext(viewModel.modelContext)
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
        viewModel.openNewMemoFlowFromShortcut()
        homeViewModel.selectedSection = viewModel.state.selectedSection
    }

    func resetNavigationState() {
        viewModel.resetNavigationState()
    }

    func resetStateForSectionChange(_ section: HomeViewModel.Section?) {
        viewModel.resetStateForSectionChange(section)
    }
}

#Preview {
    ContentView()
}
