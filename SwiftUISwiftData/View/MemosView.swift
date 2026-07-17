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
        case protect
        case unprotect
        case error
        var id: AlertType { self }
    }

    @Environment(\.scenePhase)
    private var scenePhase
    /// ビューの状態を管理するViewModel。
    @ObservedObject
    var viewModel = MemosViewModel(
        memoRepository: MemoRepository(modelContainer: ModelContainerManager.shared.modelContainer),
        userDefaultsRepository: UserDefaultsRepository()
    )
    /// 編集モードの状態を管理する状態変数。
    @Binding
    var editMode: EditMode
    /// 削除するメモを保持する状態変数。
    @State
    var memoToDelete: Memo?
    /// 選択されたメモのIDを保持する状態変数。
    @Binding
    var selectedMemo: Memo?
    /// 複数選択されたメモのIDを保持する状態変数。
    @State
    var selection: Set<UUID> = []
    /// スクロールビューのプロキシを保持する状態変数。
    @State
    private var scrollViewProxy: ScrollViewProxy?
    /// 新しいメモを追加するためのフルスクリーンカバーを表示するフラグ。
    @State
    private var showingAddMemo = false
    /// メモの内容を編集するビューを開くかどうかのフラグ。
    @Binding
    private var openEditMemoView: Bool
    /// トーストメッセージの状態変数。
    @State
    var toastMessage = ""
    @State
    var error: Error?
    @State
    var memoDuplicateSource: Memo?
    @State
    var currentAlert: AlertType?
    @State
    var searchText: String = ""
    @State
    private var isSearching: Bool = false
    @FocusState
    private var inputViewFocus: Bool

    /// イニシャライザ。
    init(
        editMode: Binding<EditMode>,
        selectedMemo: Binding<Memo?>,
        openEditMemoView: Binding<Bool>,
    ) {
        _editMode = editMode
        _selectedMemo = selectedMemo
        _openEditMemoView = openEditMemoView
    }

    var body: some View {
        VStack(spacing: 8.0) {
            if isSearching {
                InputView(
                    text: $searchText,
                    focus: _inputViewFocus,
                    placeholder: "Input keywords to search by title",
                    textFieldBackground: Color(uiColor: .secondarySystemBackground),
                    submitLabel: .done,
                    icon: .search,
                    cancelButtonTapped: {
                        isSearching = false
                        searchText = ""
                    }
                )
                .padding(.horizontal)
            }
            list
                .onChange(of: viewModel.memos) { oldMemos, newMemos in
                    onChange(oldMemos: oldMemos, newMemos: newMemos)
                }
                .alert(item: $currentAlert) { alertType in
                    switch alertType {
                        case .delete:
                            deleteAlert
                        case .containsProtectedMemo:
                            containsProtectedMemoAlert
                        case .protect:
                            protectAlert
                        case .unprotect:
                            unprotectAlert
                        case .error:
                            errorAlert
                    }
                }
                .navigationTitle(navigationTitle)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(editMode.isEditing || isSearching)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        toolbarItemTopBarTrailing
                    }
                }
                .environment(\.editMode, $editMode)
                .fullScreenCover(isPresented: $showingAddMemo) {
                    EditMemoView()
                }
                .onDisappear {
                    openEditMemoView = false
                }
                .toast(message: $toastMessage)
                .onChange(of: scenePhase) {
                    switch scenePhase {
                        case .inactive:
                            inputViewFocus = false
                        default:
                            break
                    }
                }
            if !isSearching {
                bottomBar
                    .padding(.bottom, 8)
            }
        }
    }

    /// メモのリストを表示するビュー。
    private var list: some View {
        ScrollViewReader { proxy in
            VStack {
                if editMode.isEditing {
                    List(selection: $selection) {
                        ForEach(viewModel.memos) { memo in
                            activeRow(for: memo)
                                .id(memo.id)
                                .tag(memo.id)
                        }
                        .onMove(perform: moveMemo)
                    }
                }
                else {
                    if viewModel.memos.isEmpty {
                        EmptyListView(message: "No memos")
                    }
                    else {
                        if filteredMemos.isEmpty {
                            EmptyListView(message: "No memos found")
                        }
                        else {
                            List(selection: $selectedMemo) {
                                ForEach(filteredMemos) { memo in
                                    inactiveRow(for: memo)
                                        .id(memo.id)
                                        .tag(memo.id)
                                }
                            }
                        }
                    }
                }
            }
            .onAppear {
                scrollViewProxy = proxy
            }
        }
    }

    private var bottomBar: some View {
        HStack {
            Spacer()
                .frame(width: 24)
            if editMode.isEditing {
                GlassMenu(imageSystemName: "square.and.arrow.up") {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        if selectedMemos.filter({ $0.protected }).isEmpty {
                            currentAlert = .delete
                        }
                        else {
                            currentAlert = .containsProtectedMemo
                        }
                    }
                    Divider()
                    Button("Unprotect", systemImage: "lock.open.fill") {
                        currentAlert = .unprotect
                    }
                    Button("Protect", systemImage: "lock.fill") {
                        currentAlert = .protect
                    }
                }
                .disabled(selection.isEmpty)
                Spacer()
                GlassMenu(imageSystemName: "circle.grid.2x2.topleft.checkmark.filled") {
                    Button("Deselect All", systemImage: "circle") {
                        selection.removeAll()
                    }
                    .disabled(selection.isEmpty)
                    Button("Select All", systemImage: "checkmark.circle") {
                        selection = Set(viewModel.memos.map { $0.id })
                    }
                    .disabled(selection.count == viewModel.memos.count)
                }
            }
            else {
                GlassButton(imageSystemName: "magnifyingglass") {
                    isSearching = true
                    DispatchQueue.main.async {
                        inputViewFocus = true
                    }
                }
                .disabled(viewModel.memos.isEmpty || isSearching)
                .keyboardShortcut("s", modifiers: [.command])
                Spacer()
                GlassButton(imageSystemName: "plus.circle") {
                    showingAddMemo = true
                }
                .disabled(isSearching)
                .keyboardShortcut("n", modifiers: [.command])
            }
            Spacer()
                .frame(width: 24)
        }
    }

    /// ナビゲーションタイトルを編集モードの状態に応じて動的に生成するプロパティ。
    private var navigationTitle: String {
        var title = "Memos ("
        if editMode.isEditing {
            title = title + "\(selection.count)/\(viewModel.memos.count))"
        }
        else {
            if isSearching {
                title = title + "\(filteredMemos.count)/\(viewModel.memos.count))"
            }
            else {
                title = title + "\(viewModel.memos.count))"
            }
        }
        return title
    }

    /// ツールバーの右側のアイテムを編集モードの状態に応じて動的に生成するビュー。
    @ViewBuilder
    private var toolbarItemTopBarTrailing: some View {
        if editMode.isEditing {
            Button("Done", systemImage: "checkmark") {
                selection.removeAll()
                editMode = .inactive
            }
            .keyboardShortcut(.cancelAction)
        }
        else {
            if !viewModel.memos.isEmpty {
                Button("Edit", systemImage: "pencil") {
                    selectedMemo = nil
                    editMode = .active
                }
                .disabled(isSearching)
                .keyboardShortcut("e", modifiers: [.command])
            }
        }
    }

    /// メモの配列が変更されたときに呼び出される関数。
    ///
    /// 編集モードの状態に応じて選択状態を更新したり、新しいメモが追加された場合にスクロールして表示するなどの処理を行う。
    /// - Parameters:
    ///   - oldMemos: 以前のメモの配列
    ///   - newMemos: 新しいメモの配列
    private func onChange(oldMemos: [Memo], newMemos: [Memo]) {
        switch editMode {
            case .active:
                if newMemos.isEmpty {
                    selection.removeAll()
                    editMode = .inactive
                }
            case .inactive:
                if let newMemo = newMemos.first(where: { !oldMemos.contains($0) }) {
                    if let memoDuplicateSource,
                        memoDuplicateSource.order + 1 == newMemo.order
                    {
                        self.memoDuplicateSource = nil
                        return
                    }

                    DispatchQueue.main.async {
                        var transaction = Transaction()
                        transaction.disablesAnimations = true
                        withTransaction(transaction) {
                            selection.removeAll()
                            selectedMemo = newMemo
                            if let proxy = scrollViewProxy {
                                proxy.scrollTo(newMemo.id, anchor: .center)
                            }
                        }
                    }
                }
            default:
                break
        }
    }

    /// 編集モードで表示する行のビューを生成する関数。
    ///
    /// メモをタップすると選択状態が切り替わるようになっている。
    /// - Parameter memo: 表示するメモ
    /// - Returns: 編集モードで表示する行のビュー
    private func activeRow(for memo: Memo) -> some View {
        Button {
            if selection.contains(memo.id) {
                selection.remove(memo.id)
            }
            else {
                selection.insert(memo.id)
            }
        } label: {
            ActiveRow(
                memo: memo,
                titleLineLimit: viewModel.getTitleLineLimit(),
                titleFontSize: viewModel.getTitleFontSize(),
                titleLineSpacing: viewModel.getTitleLineSpacing(),
                showInfo: viewModel.getShowInfo()
            )
        }
        .foregroundStyle(.primary)
        .padding()
        .contentShape(Rectangle())
        .listRowInsets(.init())
        .moveDisabled(false)
        .listRowBackground(Color(uiColor: .secondarySystemGroupedBackground))
    }

    /// 非編集モードで表示する行のビューを生成する関数。
    ///
    /// メモをタップすると選択され、コンテキストメニューから編集や削除ができるようになっている。
    /// - Parameter memo: 表示するメモ
    /// - Returns: 非編集モードで表示する行のビュー
    private func inactiveRow(for memo: Memo) -> some View {
        InactiveRow(
            memo: memo,
            titleLineLimit: viewModel.getTitleLineLimit(),
            titleFontSize: viewModel.getTitleFontSize(),
            titleLineSpacing: viewModel.getTitleLineSpacing(),
            showInfo: viewModel.getShowInfo(),
            searchWords: viewModel.searchWords
        )
        .contentShape(Rectangle())
        .onTapGesture {
            selectedMemo = memo
        }
        .contextMenu {
            if memo.protected {
                Button("Unprotect", systemImage: "lock.open.fill") {
                    Task {
                        await unprotect([memo])
                    }
                }
            }
            else {
                Button("Edit", systemImage: "pencil") {
                    openEditMemoView = true
                    selectedMemo = memo
                }
                Button("Duplicate", systemImage: "plus.square") {
                    duplicateMemo(memo)
                }
                Button("Delete", systemImage: "trash", role: .destructive) {
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
        } preview: {
            PreviewMemoView(memo: memo)
        }
        .listRowInsets(.init())
        .moveDisabled(true)
        .listRowBackground(Color(uiColor: memo == selectedMemo ? .quaternaryLabel : .systemBackground))
    }
}
