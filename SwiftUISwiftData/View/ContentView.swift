//
//  ContentView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/05/04.
//

import SwiftData
import SwiftUI

/// メモ、タグ、設定のナビゲーションを表示するビュー。
struct ContentView: View {
    /// 子画面で共有する依存関係。
    private struct Dependencies {
        let modelContext: ModelContext
        let memoRepository: MemoRepository
        let tagRepository: TagRepository
        let userDefaultsRepository: UserDefaultsRepository
        let suiteName: String?

        init(
            modelContext: ModelContext,
            userDefaultsRepository: UserDefaultsRepository,
            suiteName: String?
        ) {
            self.modelContext = modelContext
            memoRepository = MemoRepository(modelContext: modelContext)
            tagRepository = TagRepository(modelContext: modelContext)
            self.userDefaultsRepository = userDefaultsRepository
            self.suiteName = suiteName
        }
    }

    @State
    private var viewModel: ContentViewModel

    @State
    private var dependencies: Dependencies

    /// 通常の依存関係を使用してビューを生成する。
    init() {
        self.init(
            modelContext: ModelContainerManager.shared.modelContainer.mainContext,
            userDefaultsRepository: UserDefaultsRepository(),
            suiteName: nil,
            viewModel: ContentViewModel()
        )
    }

    /// 外部から依存関係を注入してビューを生成する。
    ///
    /// 独自の UserDefaults を使用する場合、suiteName には
    /// その UserDefaults に対応するスイート名を指定する。
    init(
        modelContext: ModelContext,
        userDefaultsRepository: UserDefaultsRepository,
        suiteName: String?,
        viewModel: ContentViewModel = ContentViewModel()
    ) {
        _viewModel = State(initialValue: viewModel)
        _dependencies = State(
            initialValue: Dependencies(
                modelContext: modelContext,
                userDefaultsRepository: userDefaultsRepository,
                suiteName: suiteName
            )
        )
    }

    var body: some View {
        NavigationSplitView {
            HomeView(viewModel: viewModel.homeViewModel)
        } content: {
            contentView
        } detail: {
            detailView
        }
        .modelContext(dependencies.modelContext)
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
                    showingAddMemo: $viewModel.state.showingAddMemo,
                    memoRepository: dependencies.memoRepository,
                    userDefaultsRepository: dependencies.userDefaultsRepository
                )
            case .tags:
                TagsView(
                    editMode: $viewModel.state.tagsViewEditMode,
                    selectedTag: $viewModel.state.selectedTag,
                    tagRepository: dependencies.tagRepository,
                    userDefaultsRepository: dependencies.userDefaultsRepository
                )
            case .settings:
                SettingsView(
                    viewModel: SettingsViewModel(
                        userDefaultsRepository: dependencies.userDefaultsRepository,
                        suiteName: dependencies.suiteName
                    )
                )
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
            BrowseMemoView(
                memo: selectedMemo,
                userDefaultsRepository: dependencies.userDefaultsRepository
            )
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
            BrowseTagView(
                tag: selectedTag,
                userDefaultsRepository: dependencies.userDefaultsRepository
            )
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
