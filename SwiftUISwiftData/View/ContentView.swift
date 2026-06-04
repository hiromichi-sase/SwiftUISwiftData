//
//  ContentView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/05/04.
//

import SwiftUI
import SwiftData

/// メモのリストを表示するビュー
struct ContentView: View {
    /// ビューの状態を管理するViewModel
    @ObservedObject var viewModel = ContentViewModel()

    /// 編集モードの状態を管理する状態変数
    @State private var editMode: EditMode = .inactive
    /// 削除するメモを保持する状態変数
    @State private var memoToDelete: Memo?
    /// 選択されたメモのIDを保持する状態変数
    @State private var selectedMemoId: UUID?
    /// 複数選択されたメモのIDを保持する状態変数
    @State private var selection: Set<UUID> = []
    /// スクロールビューのプロキシを保持する状態変数
    @State private var scrollViewProxy: ScrollViewProxy?
    /// 選択されたメモを削除するかどうかの確認アラートを表示するフラグ
    @State private var showDeleteSelectionAlert = false
    /// 新しいメモを追加するためのフルスクリーンカバーを表示するフラグ
    @State private var showingAddMemo = false
    /// メモの内容を編集するビューを開くかどうかのフラグ
    @State private var openEditMemoView = false

    var body: some View {
        NavigationSplitView {
            list
                .contentMargins([.top], 0)
            .onChange(of: viewModel.memos) { oldMemos, newMemos in
                onChange(oldMemos: oldMemos, newMemos: newMemos)
            }
            .onReceive(willSavePublisher) { _ in
                viewModel.fetchMemos()
            }
            .alert(item: $memoToDelete) { memo in
                Alert(
                    title: Text("Delete this memo?"),
                    primaryButton: .destructive(Text("Delete")) {
                        deleteMemos([memo])
                    },
                    secondaryButton: .cancel()
                )
            }
            .alert("Delete selected memos?", isPresented: $showDeleteSelectionAlert) {
                Button("Delete", role: .destructive) {
                    deleteMemos(selectedMemos)
                }
                Button("Cancel", role: .cancel) {}
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
            .onDisappear {
                openEditMemoView = false
            }
        } detail: {
            if editMode == .inactive {
                if let id = selectedMemoId,
                   let memo = viewModel.memos.first(where: { $0.id == id }) {
                    BrowseMemoView(memo: memo, openEditMemoView: openEditMemoView)
                        .modelContext(viewModel.modelContext)
                        .id(memo.id)
                } else {
                    Text("Select a memo")
                }
            } else {
                Text("Select memos to edit or delete")
            }
        }
    }

    /// メモのリストを表示するビュー
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
                } else {
                    List(selection: $selectedMemoId) {
                        ForEach(viewModel.memos) { memo in
                            inactiveRow(for: memo)
                                .id(memo.id)
                                .tag(memo.id)
                        }
                    }
                }
            }
            .onAppear {
                scrollViewProxy = proxy
            }
        }
    }

    /// ナビゲーションタイトルを編集モードの状態に応じて動的に生成するプロパティ
    private var navigationTitle: String {
        "Memos (\(editMode == .active ? "\(selection.count)/" : "")\(viewModel.memos.count))"
    }

    /// ツールバーの左側のアイテムを編集モードの状態に応じて動的に生成するビュー
    @ViewBuilder
    private var toolbarItemTopBarLeading: some View {
        if editMode == .inactive {
            if !viewModel.memos.isEmpty {
                Button("Edit", systemImage: "pencil") {
                    selectedMemoId = nil
                    editMode = .active
                }
            }
        } else {
            Button("Done", systemImage: "checkmark") {
                selection.removeAll()
                editMode = .inactive
            }
        }
    }

    /// ツールバーの右側のアイテムを編集モードの状態に応じて動的に生成するビュー
    @ViewBuilder
    private var toolbarItemTopBarTrailing: some View {
        if editMode == .inactive {
            Button("Add", systemImage: "plus.circle") {
                showingAddMemo = true
            }
        } else {
            Menu("Menu", systemImage: "ellipsis.circle") {
                Button("Select All", systemImage: "checkmark.circle") {
                    selection = Set(viewModel.memos.map { $0.id })
                }
                .disabled(selection.count == viewModel.memos.count)
                Button("Deselect All", systemImage: "circle") {
                    selection.removeAll()
                }
                .disabled(selection.count == .zero)
            }
            Button("Delete", systemImage: "trash") {
                showDeleteSelectionAlert = true
            }
            .disabled(selection.isEmpty)
        }
    }

    /// 選択されたメモの配列を返す計算プロパティ
    private var selectedMemos: [Memo] {
        viewModel.memos.filter { selection.contains($0.id) }
    }

    /// メモの配列が変更されたときに呼び出される関数。編集モードの状態に応じて選択状態を更新したり、新しいメモが追加された場合にスクロールして表示するなどの処理を行う。
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
                DispatchQueue.main.async {
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) {
                        self.selection.removeAll()
                        self.selectedMemoId = newMemo.id
                        if let proxy = self.scrollViewProxy {
                            proxy.scrollTo(newMemo.id, anchor: .center)
                        }
                    }
                }
            }
        default:
            break
        }
    }
    
    /// モデルコンテキストの保存前に通知を受け取るためのパブリッシャー。これを使用して、メモが更新されたときにビューを更新することができる。
    private var willSavePublisher: NotificationCenter.Publisher {
        NotificationCenter.default
            .publisher(for: ModelContext.willSave, object: viewModel.modelContext)
    }
}

extension ContentView {
    /// 編集モードで表示する行のビューを生成する関数。メモをタップすると選択状態が切り替わるようになっている。
    /// - Parameter memo: 表示するメモ
    /// - Returns: 編集モードで表示する行のビュー
    private func activeRow(for memo: Memo) -> some View {
        activeMemoRow(memo: memo) { memo in
            if selection.contains(memo.id) {
                selection.remove(memo.id)
            } else {
                selection.insert(memo.id)
            }
        }
        .listRowInsets(.init())
        .moveDisabled(false)
        .listRowBackground(Color(uiColor: .secondarySystemGroupedBackground))
    }

    /// 非編集モードで表示する行のビューを生成する関数。メモをタップすると選択され、コンテキストメニューから編集や削除ができるようになっている。
    private struct activeMemoRow: View {
        let memo: Memo
        let onTap: (Memo) -> Void

        var body: some View {
            Button(action: {
                onTap(memo)
            }) {
                HStack {
                    TitleText(memo.title)
                    Spacer()
                }
            }
            .foregroundStyle(.primary)
            .padding()
            .contentShape(Rectangle())
        }
    }

    /// 非編集モードで表示する行のビューを生成する関数。メモをタップすると選択され、コンテキストメニューから編集や削除ができるようになっている。
    /// - Parameter memo: 表示するメモ
    /// - Returns: 非編集モードで表示する行のビュー
    private func inactiveRow(for memo: Memo) -> some View {
        HStack {
            TitleText(memo.title)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectedMemoId = memo.id
        }
        .contextMenu {
            Button("Edit", systemImage: "pencil") {
                openEditMemoView = true
                selectedMemoId = memo.id
            }
            Button("Delete", systemImage: "trash", role: .destructive) {
                memoToDelete = memo
            }
        } preview: {
            PreviewMemoView(memo: memo)
        }
        .listRowInsets(.init())
        .moveDisabled(true)
    }
}

extension ContentView {
    /// 指定されたメモを削除する関数。削除後に選択状態を更新し、すべてのメモの順序を再計算して保存する。
    /// - Parameter memos: 削除するメモの配列
    private func deleteMemos(_ memos: [Memo]) {

        do {
            try viewModel.delete(memos)

            for memo in memos {
                if selectedMemoId == memo.id {
                    selectedMemoId = nil
                }
            }

            selection.removeAll()
            moveAllMemos()
        } catch {
            print("Failed to delete memos: \(error)")
        }
    }

    /// 指定されたメモを新しい位置に移動する関数。移動後にすべてのメモの順序を再計算して保存する。
    /// - Parameters:
    ///   - source: 移動するメモのインデックスセット
    ///   - destination: 移動先のインデックス
    private func moveMemo(from source: IndexSet, to destination: Int) {
        do {
            try viewModel.moveMemo(from: source, to: destination)
        } catch {
            print("Failed to move memo: \(error)")
        }
    }

    /// すべてのメモの順序を再計算して保存する関数。メモの順序は1から始まる整数で、配列のインデックスに基づいて割り当てられる。
    private func moveAllMemos() {
        do {
            try viewModel.renumberOrder()
        } catch {
            print("Failed to renumber order: \(error)")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(ModelContainerManager(isStoredInMemoryOnly: true).modelContainer)
}
