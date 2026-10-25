//
//  TagsView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import SwiftData
import SwiftUI

struct TagsView: View {
    enum AlertType: Identifiable {
        case delete
        case error
        var id: AlertType { self }
    }

    /// ビューの状態を管理するViewModel。
    @ObservedObject
    var viewModel = TagsViewModel(
        tagRepository: TagRepository(modelContext: ModelContainerManager.shared.modelContainer.mainContext),
        userDefaultsRepository: UserDefaultsRepository()
    )
    /// 編集モードの状態を管理する状態変数。
    @Binding
    var editMode: EditMode
    /// 削除するタグを保持する状態変数。
    @State
    var tagToDelete: Tag?
    /// 選択されたタグのIDを保持する状態変数。
    @Binding
    var selectedTag: Tag?
    /// 複数選択されたタグのIDを保持する状態変数。
    @State
    var selection: Set<UUID> = []
    /// スクロールビューのプロキシを保持する状態変数。
    @State
    private var scrollViewProxy: ScrollViewProxy?
    /// 新しいタグを追加するためのフルスクリーンカバーを表示するフラグ。
    @State
    private var showingAddTag = false
    /// トーストメッセージの状態変数。
    @State
    var toastMessage = ""
    @State
    var error: any Error?
    @State
    var currentAlert: AlertType?

    /// イニシャライザ。
    init(
        editMode: Binding<EditMode>,
        selectedTag: Binding<Tag?>,
    ) {
        _editMode = editMode
        _selectedTag = selectedTag
    }

    var body: some View {
        VStack(spacing: 8.0) {
            list
                .onChange(of: viewModel.tags) { oldTags, newTags in
                    onChange(oldTags: oldTags, newTags: newTags)
                }
                .alert(item: $currentAlert) { alertType in
                    switch alertType {
                        case .delete:
                            deleteAlert
                        case .error:
                            errorAlert
                    }
                }
                .navigationTitle(navigationTitle)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(editMode.isEditing)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        toolbarItemTopBarTrailing
                    }
                }
                .environment(\.editMode, $editMode)
                .sheet(isPresented: $showingAddTag) {
                    EditTagView()
                        .interactiveDismissDisabled(true)
                }
                .onReceive(NotificationCenter.default.publisher(for: .closeAllPresentedViewsFromShortcut)) { _ in
                    showingAddTag = false
                    selectedTag = nil
                    selection.removeAll()
                    editMode = .inactive
                    tagToDelete = nil
                    currentAlert = nil
                }
                .toast(message: $toastMessage)
            bottomBar
                .padding(.bottom, 8)
        }
    }

    /// タグのリストを表示するビュー。
    private var list: some View {
        ScrollViewReader { proxy in
            VStack {
                if editMode.isEditing {
                    List(selection: $selection) {
                        ForEach(viewModel.tags) { tag in
                            activeRow(for: tag)
                                .id(tag.id)
                                .tag(tag.id)
                        }
                        .onMove(perform: moveTag)
                    }
                }
                else {
                    if viewModel.tags.isEmpty {
                        EmptyListView(message: "No Tags")
                    }
                    else {
                        List(selection: $selectedTag) {
                            ForEach(viewModel.tags) { tag in
                                inactiveRow(for: tag)
                                    .id(tag.id)
                                    .tag(tag.id)
                                    .if(!tag.title.isEmpty) { view in
                                        view.swipeActions(
                                            edge: .leading,
                                            allowsFullSwipe: false
                                        ) {
                                            Button(
                                                "Copy",
                                                systemImage: "doc.on.doc"
                                            ) {
                                                UIPasteboard.general.string = tag.title
                                            }
                                            .tint(.green)
                                        }
                                    }
                                    .swipeActions(
                                        edge: .trailing,
                                        allowsFullSwipe: false
                                    ) {
                                        Button("Delete", systemImage: "trash", role: .destructive) {
                                            tagToDelete = tag
                                            currentAlert = .delete
                                        }
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
                GlassButton(imageSystemName: "trash") {
                    currentAlert = .delete
                }
                .disabled(selection.isEmpty)
                Spacer()
                GlassMenu(imageSystemName: "circle.grid.2x2.topleft.checkmark.filled") {
                    Button("Deselect All", systemImage: "circle") {
                        selection.removeAll()
                    }
                    .disabled(selection.isEmpty)
                    Button("Select All", systemImage: "checkmark.circle") {
                        selection = Set(viewModel.tags.map { $0.id })
                    }
                    .disabled(selection.count == viewModel.tags.count)
                }
            }
            else {
                Spacer()
                GlassButton(imageSystemName: "plus.circle") {
                    showingAddTag = true
                }
                .keyboardShortcut("n", modifiers: [.command])
            }
            Spacer()
                .frame(width: 24)
        }
    }

    /// ナビゲーションタイトルを編集モードの状態に応じて動的に生成するプロパティ。
    private var navigationTitle: String {
        var title = "Tags ("
        if editMode.isEditing {
            title = title + "\(selection.count)/\(viewModel.tags.count))"
        }
        else {
            title = title + "\(viewModel.tags.count))"
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
            if !viewModel.tags.isEmpty {
                Button("Edit", systemImage: "pencil") {
                    selectedTag = nil
                    editMode = .active
                }
                .keyboardShortcut("e", modifiers: [.command])
            }
        }
    }

    /// タグの配列が変更されたときに呼び出される関数。
    ///
    /// 編集モードの状態に応じて選択状態を更新したり、新しいタグが追加された場合にスクロールして表示するなどの処理を行う。
    /// - Parameters:
    ///   - oldTags: 以前のタグの配列
    ///   - newTags: 新しいタグの配列
    private func onChange(oldTags: [Tag], newTags: [Tag]) {
        switch editMode {
            case .active:
                if newTags.isEmpty {
                    selection.removeAll()
                    editMode = .inactive
                }
            case .inactive:
                if let newTag = newTags.first(where: { !oldTags.contains($0) }) {
                    DispatchQueue.main.async {
                        var transaction = Transaction()
                        transaction.disablesAnimations = true
                        withTransaction(transaction) {
                            selection.removeAll()
                            selectedTag = newTag
                            if let proxy = scrollViewProxy {
                                proxy.scrollTo(newTag.id, anchor: .center)
                            }
                        }
                    }
                }
            default:
                break
        }
    }

    private func makeTagRow(for tag: Tag) -> TagRow {
        TagRow(
            tag: tag,
            titleLineLimit: viewModel.getTitleLineLimit(),
            titleFontSize: viewModel.getTitleFontSize(),
            titleLineSpacing: viewModel.getTitleLineSpacing(),
            showColorString: true,
            showInfo: viewModel.getShowInfo(),
            showTagCount: true,
        )
    }

    private func toggleSelection(for id: UUID) {
        if selection.contains(id) {
            selection.remove(id)
        }
        else {
            selection.insert(id)
        }
    }

    /// 編集モードで表示する行のビューを生成する関数。
    ///
    /// タグをタップすると選択状態が切り替わるようになっている。
    /// - Parameter tag: 表示するタグ
    /// - Returns: 編集モードで表示する行のビュー
    private func activeRow(for tag: Tag) -> some View {
        Button {
            toggleSelection(for: tag.id)
        } label: {
            makeTagRow(for: tag)
        }
        .foregroundStyle(.primary)
        .contentShape(Rectangle())
        .listRowInsets(.init())
        .moveDisabled(false)
        .listRowBackground(Color(uiColor: .secondarySystemGroupedBackground))
    }

    /// 非編集モードで表示する行のビューを生成する関数。
    ///
    /// タグをタップすると選択される。
    /// - Parameter tag: 表示するタグ
    /// - Returns: 非編集モードで表示する行のビュー
    private func inactiveRow(for tag: Tag) -> some View {
        makeTagRow(for: tag)
            .contentShape(Rectangle())
            .onTapGesture {
                selectedTag = tag
            }
            .contextMenu {
                Button("Preview", systemImage: "eye") {
                    selectedTag = tag
                }
            }
            .listRowInsets(.init())
            .moveDisabled(true)
            .listRowBackground(Color(uiColor: tag == selectedTag ? .quaternaryLabel : .systemBackground))
    }
}
