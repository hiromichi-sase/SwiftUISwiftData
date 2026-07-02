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
    var viewModel = ContentViewModel(
        memoRepository: MemoRepository(modelContainer: ModelContainerManager.shared.modelContainer),
        userDefaultsRepository: UserDefaultsRepository()
    )
    /// 編集モードの状態を管理する状態変数。
    @State
    private var editMode: EditMode = .inactive
    /// 削除するメモを保持する状態変数。
    @State
    private var memoToDelete: Memo?
    /// 選択されたメモのIDを保持する状態変数。
    @State
    private var selectedMemoId: UUID?
    /// 複数選択されたメモのIDを保持する状態変数。
    @State
    private var selection: Set<UUID> = []
    /// スクロールビューのプロキシを保持する状態変数。
    @State
    private var scrollViewProxy: ScrollViewProxy?
    /// 新しいメモを追加するためのフルスクリーンカバーを表示するフラグ。
    @State
    private var showingAddMemo = false
    /// メモの内容を編集するビューを開くかどうかのフラグ。
    @State
    private var openEditMemoView = false
    /// 設定画面をフルスクリーンカバーで表示するフラグ。
    @State
    private var showSettingsView = false
    /// トーストメッセージの状態変数。
    @State
    private var toastMessage = ""
    /// 設定画面で変更保存したかどうかのフラグ。
    @State
    private var settingsSaved = false
    @State
    private var error: Error?
    @State
    private var memoDuplicateSource: Memo?
    @State
    private var currentAlert: AlertType?
    @State
    private var searchText: String = ""
    @State
    private var isSearching: Bool = false
    @FocusState
    private var searchViewFocus: Bool
    private var filteredMemos: [Memo] {
        viewModel.filteredMemos(by: searchText)
    }

    /// イニシャライザ。
    init() {
        _toastMessage = State(initialValue: "")
        _error = State(initialValue: nil)
    }

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 8.0) {
                if isSearching {
                    SearchView(
                        text: $searchText,
                        focus: _searchViewFocus,
                        placeholder: "Input keywords to search by title"
                    ) {
                        isSearching = false
                        searchText = ""
                    }
                    .padding(.horizontal)
                }
                list
                    .contentMargins([.top], .zero)
                    .onChange(of: viewModel.memos) { oldMemos, newMemos in
                        onChange(oldMemos: oldMemos, newMemos: newMemos)
                    }
                    .onChange(of: settingsSaved) { _, _ in
                        guard settingsSaved else { return }
                        viewModel.fetchMemos()
                        settingsSaved = false
                    }
                    .onReceive(willSavePublisher) { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            viewModel.fetchMemos()
                        }
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
                    .toolbar {
                        ToolbarItemGroup(placement: .topBarLeading) {
                            toolbarItemTopBarLeading
                        }
                        ToolbarItemGroup(placement: .topBarTrailing) {
                            toolbarItemTopBarTrailing
                        }
                    }
                    .environment(\.editMode, $editMode)
                    .fullScreenCover(isPresented: $showingAddMemo) {
                        EditMemoView()
                    }
                    .sheet(isPresented: $showSettingsView) {
                        SettingsView(settingsSaved: $settingsSaved)
                    }
                    .onDisappear {
                        openEditMemoView = false
                    }
                    .toast(message: $toastMessage)
                    .onChange(of: scenePhase) {
                        switch scenePhase {
                            case .inactive:
                                searchViewFocus = false
                            default:
                                break
                        }
                    }
            }
            .background(Color("ContentViewListBackground"))
        } detail: {
            detailView
        }
    }

    private var deleteAlert: Alert {
        .init(
            title: Text("Delete \(editMode == .active ? "selected memos" : "this memo")?"),
            primaryButton: .destructive(Text("Delete")) {
                if editMode == .active {
                    guard !selectedMemos.isEmpty else { return }
                    deleteMemos(selectedMemos)
                }
                else {
                    guard let memoToDelete = memoToDelete else { return }
                    deleteMemos([memoToDelete])
                }
            },
            secondaryButton: .cancel()
        )
    }

    private var errorAlert: Alert {
        .init(
            title: Text("The Error occured."),
            message: Text(error?.localizedDescription ?? ""),
            dismissButton: .default(Text("OK"))
        )
    }

    private var containsProtectedMemoAlert: Alert {
        .init(
            title: Text("Protected memos are contained in selected memos."),
            message: Text(error?.localizedDescription ?? ""),
            dismissButton: .default(Text("OK"))
        )
    }

    private var protectAlert: Alert {
        .init(
            title: Text("Protect selected memos?"),
            primaryButton: .default(Text("Protect")) {
                guard !selectedMemos.isEmpty else { return }
                Task {
                    await protect(selectedMemos)
                }
            },
            secondaryButton: .cancel()
        )
    }

    private var unprotectAlert: Alert {
        .init(
            title: Text("Unprotect selected memos?"),
            primaryButton: .default(Text("Unprotect")) {
                guard !selectedMemos.isEmpty else { return }
                Task {
                    await unprotect(selectedMemos)
                }
            },
            secondaryButton: .cancel()
        )
    }

    /// メモのリストを表示するビュー。
    private var list: some View {
        ScrollViewReader { proxy in
            VStack {
                if editMode == .active {
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
                    if filteredMemos.isEmpty {
                        EmptyListView(message: "No memos found")
                    }
                    else {
                        List(selection: $selectedMemoId) {
                            ForEach(filteredMemos) { memo in
                                inactiveRow(for: memo)
                                    .id(memo.id)
                                    .tag(memo.id)
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

    /// ナビゲーションタイトルを編集モードの状態に応じて動的に生成するプロパティ。
    private var navigationTitle: String {
        var title = "Memos ("
        if editMode == .active {
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

    /// ツールバーの左側のアイテムを編集モードの状態に応じて動的に生成するビュー。
    @ViewBuilder
    private var toolbarItemTopBarLeading: some View {
        if editMode == .inactive {
            if !viewModel.memos.isEmpty {
                Button("Edit", systemImage: "pencil") {
                    selectedMemoId = nil
                    editMode = .active
                }
                .disabled(isSearching)
                .keyboardShortcut("e", modifiers: [.command])
            }
            Button("Settings", systemImage: "gearshape.fill") {
                showSettingsView = true
            }
            .disabled(isSearching)
            .keyboardShortcut(",", modifiers: [.command, .shift])
        }
        else {
            Button("Done", systemImage: "checkmark") {
                selection.removeAll()
                editMode = .inactive
            }
            .keyboardShortcut(".", modifiers: [.command])
        }
    }

    /// ツールバーの右側のアイテムを編集モードの状態に応じて動的に生成するビュー。
    @ViewBuilder
    private var toolbarItemTopBarTrailing: some View {
        if editMode == .inactive {
            Button("Add", systemImage: "plus.circle") {
                showingAddMemo = true
            }
            .disabled(isSearching)
            .keyboardShortcut("n", modifiers: [.command])
            Button("Search", systemImage: "magnifyingglass") {
                isSearching.toggle()
                if isSearching {
                    DispatchQueue.main.async {
                        searchViewFocus = true
                    }
                }
                else {
                    searchText = ""
                }
            }
            .disabled(viewModel.memos.isEmpty)
            .keyboardShortcut("s", modifiers: [.command])
        }
        else {
            Menu("Action", systemImage: "square.and.arrow.up") {
                Button("Protect", systemImage: "lock.fill") {
                    currentAlert = .protect
                }
                Button("Unprotect", systemImage: "lock.open.fill") {
                    currentAlert = .unprotect
                }
                Divider()
                Button("Delete", systemImage: "trash", role: .destructive) {
                    if selectedMemos.filter({ $0.protected }).isEmpty {
                        currentAlert = .delete
                    }
                    else {
                        currentAlert = .containsProtectedMemo
                    }
                }
            }
            .disabled(selection.isEmpty)
            Menu("Select", systemImage: "circle.grid.2x2.topleft.checkmark.filled") {
                Button("Select All", systemImage: "checkmark.circle") {
                    selection = Set(viewModel.memos.map { $0.id })
                }
                .disabled(selection.count == viewModel.memos.count)
                Button("Deselect All", systemImage: "circle") {
                    selection.removeAll()
                }
                .disabled(selection.isEmpty)
            }
        }
    }

    /// 選択されたメモの配列を返す計算プロパティ。
    private var selectedMemos: [Memo] {
        viewModel.memos.filter { selection.contains($0.id) }
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
                            selectedMemoId = newMemo.id
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

    @ViewBuilder
    private var detailView: some View {
        if editMode == .inactive {
            if let id = selectedMemoId,
                let memo = viewModel.memos.first(where: { $0.id == id })
            {
                BrowseMemoView(memo: memo, openEditMemoView: openEditMemoView)
                    .modelContext(viewModel.modelContext)
                    .id(memo.id)
            }
            else {
                if filteredMemos.isEmpty {
                    Text("")
                }
                else {
                    Text("Select a memo")
                }
            }
        }
        else {
            Text("Select memos to edit or delete")
        }
    }

    /// モデルコンテキストの保存前に通知を受け取るためのパブリッシャー。
    ///
    /// これを使用して、メモが更新されたときにビューを更新することができる。
    private var willSavePublisher: NotificationCenter.Publisher {
        NotificationCenter.default
            .publisher(for: ModelContext.willSave, object: viewModel.modelContext)
    }
}

extension ContentView {
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
            selectedMemoId = memo.id
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
                    selectedMemoId = memo.id
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
    }
}

extension ContentView {
    private func duplicateMemo(_ memo: Memo) {
        do {
            memoDuplicateSource = memo
            try viewModel.duplicate(memo)
            toastMessage = "Successfully duplicated!"
        }
        catch {
            memoDuplicateSource = nil
            self.error = error
            currentAlert = .error
            print("Failed to duplicate memo: \(memo)")
        }
    }

    /// 指定されたメモを削除する関数。
    ///
    /// 削除後に選択状態を更新し、すべてのメモの順序を再計算して保存する。
    /// - Parameter memos: 削除するメモの配列
    private func deleteMemos(_ memos: [Memo]) {
        do {
            try viewModel.delete(memos)

            for memo in memos where selectedMemoId == memo.id {
                selectedMemoId = nil
            }

            selection.removeAll()
            toastMessage = "Successfully deleted!"
        }
        catch {
            self.error = error
            currentAlert = .error
            print("Failed to delete memos: \(error)")
        }
    }

    /// 指定されたメモを新しい位置に移動する関数。
    ///
    /// 移動後にすべてのメモの順序を再計算して保存する。
    /// - Parameters:
    ///   - source: 移動するメモのインデックス
    ///   - destination: 移動先のインデックス
    private func moveMemo(from source: IndexSet, to destination: Int) {
        let indices = source.map { $0 }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                try viewModel.moveMemo(from: indices, to: destination)
            }
            catch {
                self.error = error
                currentAlert = .error
                print("Failed to move memo: \(error)")
            }
        }
    }

    private func protect(_ memos: [Memo]) async {
        do {
            guard try await authenticate() else { return }
            try viewModel.protect(memos)
        }
        catch {
            self.error = error
            currentAlert = .error
            print("Failed to protect memos: \(error)")
        }
    }

    private func unprotect(_ memos: [Memo]) async {
        do {
            guard try await authenticate() else { return }
            try viewModel.unprotect(memos)
        }
        catch {
            self.error = error
            currentAlert = .error
            print("Failed to unprotect memos: \(error)")
        }
    }

    private func authenticate() async throws -> Bool {
        let result = try await AuthenticationManager.shared.authenticate()
        guard result.success else {
            guard let error = result.error else {
                fatalError("Failed to get error from result.")
            }
            throw error
        }
        return result.success
    }
}

#Preview {
    ContentView()
        .modelContainer(ModelContainerManager(isStoredInMemoryOnly: true).modelContainer)
}
