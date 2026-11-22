//
//  MemosView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/03.
//

import SwiftData
import SwiftUI

struct MemosView: View {
    enum AlertType: Identifiable {
        case delete
        case containsProtectedMemo
        case error
        var id: AlertType { self }
    }

    // MemosView+CRUD.swift と MemosView+Alert.swift からも参照する。
    @State
    var viewModel: MemosViewModel
    @Binding
    var editMode: EditMode
    @State
    var memoToDelete: Memo?
    @Binding
    var selectedMemo: Memo?
    @State
    private var scrollViewProxy: ScrollViewProxy?
    @Binding
    private var showingAddMemo: Bool
    @State
    var toastMessage = ""
    @State
    var error: any Error?
    @State
    var currentAlert: AlertType?
    @State
    private var openFilterMemosView = false

    /// 通常の依存関係を使用してビューを生成する。
    init(
        editMode: Binding<EditMode>,
        selectedMemo: Binding<Memo?>,
        showingAddMemo: Binding<Bool>
    ) {
        self.init(
            editMode: editMode,
            selectedMemo: selectedMemo,
            showingAddMemo: showingAddMemo,
            memoRepository: MemoRepository(
                modelContext: ModelContainerManager.shared.modelContainer.mainContext
            ),
            userDefaultsRepository: UserDefaultsRepository()
        )
    }

    /// 外部から Repository を注入してビューを生成する。
    init(
        editMode: Binding<EditMode>,
        selectedMemo: Binding<Memo?>,
        showingAddMemo: Binding<Bool>,
        memoRepository: MemoRepository,
        userDefaultsRepository: UserDefaultsRepository
    ) {
        self.init(
            editMode: editMode,
            selectedMemo: selectedMemo,
            showingAddMemo: showingAddMemo,
            viewModel: MemosViewModel(
                memoRepository: memoRepository,
                userDefaultsRepository: userDefaultsRepository
            )
        )
    }

    /// 外部で生成した ViewModel を使用する。
    init(
        editMode: Binding<EditMode>,
        selectedMemo: Binding<Memo?>,
        showingAddMemo: Binding<Bool>,
        viewModel: MemosViewModel
    ) {
        _editMode = editMode
        _selectedMemo = selectedMemo
        _showingAddMemo = showingAddMemo
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 8.0) {
            list
                .onAppear {
                    viewModel.applyFilter()
                }
                .onChange(of: viewModel.memos) { oldMemos, newMemos in
                    handleMemosChanged(
                        oldMemos: oldMemos,
                        newMemos: newMemos
                    )
                }
                .alert(item: $currentAlert) { alertType in
                    switch alertType {
                        case .delete:
                            deleteAlert
                        case .containsProtectedMemo:
                            containsProtectedMemoAlert
                        case .error:
                            errorAlert
                    }
                }
                .navigationTitle(viewModel.navigationTitle(editMode: editMode))
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(
                    editMode.isEditing || viewModel.isFiltering
                )
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        toolbarItemTopBarTrailing
                    }
                    ToolbarItemGroup(placement: .bottomBar) {
                        toolbarItemBottomBar
                    }
                }
                .environment(\.editMode, $editMode)
                .sheet(isPresented: $openFilterMemosView) {
                    filterMemosView
                }
                .onReceive(
                    NotificationCenter.default.publisher(
                        for: .closeAllPresentedViewsFromShortcut
                    )
                ) { _ in
                    openFilterMemosView = false
                    viewModel.clearFilter()
                }
                .fullScreenCover(isPresented: $showingAddMemo) {
                    EditMemoView(
                        viewModel: viewModel.makeEditMemoViewModel()
                    )
                }
                .toast(message: $toastMessage)
        }
    }

    private var filterMemosView: some View {
        FilterMemosView(
            isFiltering: Binding(
                get: { viewModel.isFiltering },
                set: { newValue in
                    if newValue {
                        viewModel.applyFilter()
                    }
                    else {
                        viewModel.clearFilter()
                    }
                }
            ),
            title: $viewModel.filterQuery,
            tagsForFiltering: $viewModel.filterTags,
            selectedMemo: $selectedMemo,
            viewModel: viewModel.makeFilterMemosViewModel()
        )
        .interactiveDismissDisabled(true)
        .onDisappear {
            viewModel.applyFilter()
        }
    }

    private var list: some View {
        ScrollViewReader { proxy in
            VStack {
                if editMode.isEditing {
                    editingList
                }
                else {
                    normalList
                }
            }
            .onAppear {
                scrollViewProxy = proxy
            }
        }
    }

    private var editingList: some View {
        List(selection: $viewModel.selection) {
            ForEach(viewModel.memos) { memo in
                activeRow(for: memo)
                    .id(memo.id)
                    .tag(memo.id)
            }
            .onMove(perform: moveMemo)
        }
    }

    @ViewBuilder
    private var normalList: some View {
        if viewModel.memos.isEmpty {
            EmptyListView(message: "No memos")
        }
        else if viewModel.filteredMemos.isEmpty {
            EmptyListView(message: "No memos found")
        }
        else {
            List(selection: $selectedMemo) {
                ForEach(viewModel.filteredMemos) { memo in
                    inactiveRow(for: memo)
                        .id(memo.id)
                        .tag(memo.id)
                        .swipeActions(
                            edge: .leading,
                            allowsFullSwipe: false
                        ) {
                            leadingSwipeActions(for: memo)
                        }
                        .swipeActions(
                            edge: .trailing,
                            allowsFullSwipe: false
                        ) {
                            trailingSwipeActions(for: memo)
                        }
                }
            }
        }
    }

    @ViewBuilder
    private func leadingSwipeActions(for memo: Memo) -> some View {
        if !memo.title.isEmpty {
            Button("Copy", systemImage: "doc.on.doc") {
                UIPasteboard.general.string = memo.title
            }
            .tint(.green)
        }
        if !memo.protected {
            Button("Duplicate", systemImage: "plus.square") {
                duplicateMemo(memo)
            }
            .tint(.blue)
        }
    }

    @ViewBuilder
    private func trailingSwipeActions(for memo: Memo) -> some View {
        if memo.protected {
            Button("Unprotect", systemImage: "lock.open.fill") {
                Task {
                    await unprotect([memo])
                }
            }
        }
        else {
            Button(
                "Delete",
                systemImage: "trash",
                role: .destructive
            ) {
                memoToDelete = memo
                currentAlert = .delete
            }
            Divider()
            Button("Protect", systemImage: "lock.fill") {
                Task {
                    await protect([memo])
                }
            }
        }
    }

    @ViewBuilder
    private var toolbarItemTopBarTrailing: some View {
        if editMode.isEditing {
            Button("Done", systemImage: "checkmark") {
                viewModel.deselectAll()
                editMode = .inactive
            }
            .keyboardShortcut(.cancelAction)
        }
        else if !viewModel.memos.isEmpty {
            Button("Edit", systemImage: "pencil") {
                selectedMemo = nil
                editMode = .active
            }
            .disabled(viewModel.isFiltering)
            .keyboardShortcut("e", modifiers: [.command])
        }
    }

    @ViewBuilder
    private var toolbarItemBottomBar: some View {
        if editMode.isEditing {
            Button("Delete", systemImage: "trash") {
                currentAlert =
                    viewModel.containsProtectedSelectedMemo
                    ? .containsProtectedMemo
                    : .delete
            }
            .disabled(viewModel.selection.isEmpty)
        }
        else {
            Button(
                "Filter",
                systemImage: viewModel.isFiltering
                    ? "line.3.horizontal.decrease.circle.fill"
                    : "line.3.horizontal.decrease.circle"
            ) {
                openFilterMemosView = true
            }
            .disabled(viewModel.memos.isEmpty)
            .keyboardShortcut("s", modifiers: [.command])
        }
        Spacer()
        if editMode.isEditing {
            GlassMenu(
                imageSystemName: "circle.grid.2x2.topleft.checkmark.filled"
            ) {
                Button("Deselect All", systemImage: "circle") {
                    viewModel.deselectAll()
                }
                .disabled(viewModel.selection.isEmpty)

                Button("Select All", systemImage: "checkmark.circle") {
                    viewModel.selectAll()
                }
                .disabled(viewModel.selection.count == viewModel.memos.count)
            }
        }
        else {
            Button("Add", systemImage: "plus.circle") {
                showingAddMemo = true
            }
            .disabled(viewModel.isFiltering)
            .keyboardShortcut("n", modifiers: [.command])
        }
    }

    private func makeMemoRow(for memo: Memo) -> MemoRow {
        MemoRow(
            memo: memo,
            titleLineLimit: viewModel.getTitleLineLimit(),
            titleFontSize: viewModel.getTitleFontSize(),
            titleLineSpacing: viewModel.getTitleLineSpacing(),
            showInfo: viewModel.getShowInfo(),
            keywordsForFiltering: viewModel.keywordsForFiltering,
            tagsForFiltering: viewModel.filterTags
        )
    }

    private func activeRow(for memo: Memo) -> some View {
        Button {
            viewModel.toggleSelection(for: memo.id)
        } label: {
            makeMemoRow(for: memo)
        }
        .foregroundStyle(.primary)
        .contentShape(Rectangle())
        .listRowInsets(.init())
        .moveDisabled(false)
        .listRowBackground(
            Color(uiColor: .secondarySystemGroupedBackground)
        )
    }

    private func inactiveRow(for memo: Memo) -> some View {
        makeMemoRow(for: memo)
            .contentShape(Rectangle())
            .onTapGesture {
                selectedMemo = memo
            }
            .contextMenu {
                Button("Preview", systemImage: "eye") {
                    selectedMemo = memo
                }
            } preview: {
                PreviewMemoView(
                    viewModel: viewModel.makePreviewMemoViewModel(memo: memo)
                )
            }
            .listRowInsets(.init())
            .moveDisabled(true)
            .listRowBackground(
                Color(
                    uiColor: memo == selectedMemo
                        ? .quaternaryLabel
                        : .systemBackground
                )
            )
    }

    private func handleMemosChanged(
        oldMemos: [Memo],
        newMemos: [Memo]
    ) {
        selectedMemo = viewModel.selectedMemoAfterMemosChanged(
            oldMemos: oldMemos,
            newMemos: newMemos,
            editMode: editMode,
            currentSelectedMemo: selectedMemo
        )

        if editMode == .inactive,
            let memo = selectedMemo,
            let proxy = scrollViewProxy
        {
            DispatchQueue.main.async {
                var transaction = Transaction()
                transaction.disablesAnimations = true

                withTransaction(transaction) {
                    proxy.scrollTo(memo.id, anchor: .center)
                }
            }
        }

        if editMode == .active, newMemos.isEmpty {
            editMode = .inactive
        }
    }
}
