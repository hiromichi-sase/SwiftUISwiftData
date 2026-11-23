//
//  TagsView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import SwiftData
import SwiftUI

struct TagsView: View {
    @State
    private var viewModel: TagsViewModel
    @State
    private var scrollViewProxy: ScrollViewProxy?
    @Binding
    private var editMode: EditMode
    @Binding
    private var selectedTag: Tag?

    /// 通常の依存関係を使用してビューを生成する。
    init(
        editMode: Binding<EditMode>,
        selectedTag: Binding<Tag?>
    ) {
        self.init(
            editMode: editMode,
            selectedTag: selectedTag,
            tagRepository: TagRepository(
                modelContext: ModelContainerManager.shared.modelContainer.mainContext
            ),
            userDefaultsRepository: UserDefaultsRepository()
        )
    }

    /// 外部から Repository を注入してビューを生成する。
    init(
        editMode: Binding<EditMode>,
        selectedTag: Binding<Tag?>,
        tagRepository: TagRepository,
        userDefaultsRepository: UserDefaultsRepository
    ) {
        self.init(
            editMode: editMode,
            selectedTag: selectedTag,
            viewModel: TagsViewModel(
                tagRepository: tagRepository,
                userDefaultsRepository: userDefaultsRepository
            )
        )
    }

    /// 外部で生成した ViewModel を使用する。
    init(
        editMode: Binding<EditMode>,
        selectedTag: Binding<Tag?>,
        viewModel: TagsViewModel
    ) {
        _editMode = editMode
        _selectedTag = selectedTag
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 8.0) {
            list
                .onAppear {
                    syncExternalState()
                }
                .onChange(of: editMode) { _, newValue in
                    if viewModel.editMode != newValue {
                        viewModel.editMode = newValue
                    }
                }
                .onChange(of: selectedTag) { _, newValue in
                    if viewModel.selectedTag != newValue {
                        viewModel.selectedTag = newValue
                    }
                }
                .onChange(of: viewModel.editMode) { _, newValue in
                    if editMode != newValue {
                        editMode = newValue
                    }
                }
                .onChange(of: viewModel.selectedTag) { _, newValue in
                    if selectedTag != newValue {
                        selectedTag = newValue
                    }
                }
                .onChange(of: viewModel.tags) { oldTags, newTags in
                    handleTagsChanged(
                        oldTags: oldTags,
                        newTags: newTags
                    )
                }
                .alert(item: $viewModel.currentAlert) { alertType in
                    alert(for: alertType)
                }
                .navigationTitle(
                    viewModel.fetchErrorMessage == nil
                        ? viewModel.navigationTitle
                        : "Tags"
                )
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(viewModel.editMode.isEditing)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        toolbarTopTrailing
                    }
                    ToolbarItemGroup(placement: .bottomBar) {
                        Group {
                            toolbarBottomBar
                        }
                        .disabled(viewModel.fetchErrorMessage != nil)
                    }
                }
                .environment(\.editMode, $viewModel.editMode)
                .sheet(isPresented: $viewModel.showingAddTag) {
                    EditTagView(
                        viewModel: viewModel.makeEditTagViewModel()
                    )
                    .interactiveDismissDisabled(true)
                }
                .onReceive(
                    NotificationCenter.default.publisher(
                        for: .closeAllPresentedViewsFromShortcut
                    )
                ) { _ in
                    viewModel.onCloseAllPresentedViews()
                }
                .toast(message: $viewModel.toastMessage)
        }
    }

    // MARK: - State Synchronization

    private func syncExternalState() {
        if viewModel.editMode != editMode {
            viewModel.editMode = editMode
        }

        if viewModel.selectedTag != selectedTag {
            viewModel.selectedTag = selectedTag
        }
    }

    private func handleTagsChanged(
        oldTags: [Tag],
        newTags: [Tag]
    ) {
        viewModel.onTagsChanged(
            oldTags: oldTags,
            newTags: newTags
        )

        guard let id = viewModel.consumeScrollTargetID(),
            let proxy = scrollViewProxy
        else {
            return
        }

        var transaction = Transaction()
        transaction.disablesAnimations = true

        withTransaction(transaction) {
            proxy.scrollTo(id, anchor: .center)
        }
    }

    // MARK: - List

    @ViewBuilder
    private var list: some View {
        if let message = viewModel.fetchErrorMessage {
            fetchErrorView(message: message)
        }
        else {
            ScrollViewReader { proxy in
                VStack {
                    if viewModel.editMode.isEditing {
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
    }

    private func fetchErrorView(message: String) -> some View {
        VStack(spacing: 12) {
            Text("Unable to load tags")
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Retry") {
                viewModel.retryFetchTags()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var editingList: some View {
        List(selection: $viewModel.selection) {
            ForEach(viewModel.tags) { tag in
                activeRow(for: tag)
                    .id(tag.id)
                    .tag(tag.id)
            }
            .onMove(perform: viewModel.moveTag)
        }
    }

    @ViewBuilder
    private var normalList: some View {
        if viewModel.tags.isEmpty {
            EmptyListView(message: "No Tags")
        }
        else {
            List(selection: $viewModel.selectedTag) {
                ForEach(viewModel.tags) { tag in
                    inactiveRow(for: tag)
                        .id(tag.id)
                        .tag(tag.id)
                        .if(!tag.title.isEmpty) { view in
                            view.swipeActions(
                                edge: .leading,
                                allowsFullSwipe: false
                            ) {
                                Button("Copy", systemImage: "doc.on.doc") {
                                    UIPasteboard.general.string = tag.title
                                }
                                .tint(.green)
                            }
                        }
                        .swipeActions(
                            edge: .trailing,
                            allowsFullSwipe: false
                        ) {
                            Button(
                                "Delete",
                                systemImage: "trash",
                                role: .destructive
                            ) {
                                viewModel.onTapDelete(tag: tag)
                            }
                        }
                }
            }
        }
    }

    // MARK: - Alerts

    private func alert(for alertType: TagsViewModel.AlertType) -> Alert {
        switch alertType {
            case .delete:
                Alert(
                    title: Text("Delete"),
                    message: Text("Are you sure you want to delete selected tag(s)?"),
                    primaryButton: .destructive(Text("Delete")) {
                        viewModel.confirmDelete()
                    },
                    secondaryButton: .cancel()
                )

            case .error:
                Alert(
                    title: Text("Error"),
                    message: Text(
                        viewModel.error?.localizedDescription ?? "Unknown error"
                    ),
                    dismissButton: .default(Text("OK"))
                )
        }
    }

    // MARK: - Toolbar

    @ViewBuilder
    private var toolbarTopTrailing: some View {
        if viewModel.editMode.isEditing {
            // 取得失敗中も編集モードを終了できる。
            Button("Done", systemImage: "checkmark") {
                viewModel.onTapDone()
            }
            .keyboardShortcut(.cancelAction)
        }
        else if !viewModel.tags.isEmpty {
            Button("Edit", systemImage: "pencil") {
                viewModel.onTapEdit()
            }
            .disabled(viewModel.fetchErrorMessage != nil)
            .keyboardShortcut("e", modifiers: [.command])
        }
    }

    @ViewBuilder
    private var toolbarBottomBar: some View {
        if viewModel.editMode.isEditing {
            Button("trash", systemImage: "trash") {
                viewModel.onTapDelete(tag: nil)
            }
            .disabled(!viewModel.canDeleteInEditMode)

            Spacer()

            GlassMenu(
                imageSystemName: "circle.grid.2x2.topleft.checkmark.filled"
            ) {
                Button("Deselect All", systemImage: "circle") {
                    viewModel.onTapDeselectAll()
                }
                .disabled(viewModel.selection.isEmpty)

                Button("Select All", systemImage: "checkmark.circle") {
                    viewModel.onTapSelectAll()
                }
                .disabled(!viewModel.canSelectAll)
            }
        }
        else {
            Spacer()
            Button("Add", systemImage: "plus.circle") {
                viewModel.onTapAdd()
            }
            .keyboardShortcut("n", modifiers: [.command])
        }
    }

    // MARK: - Rows

    private func makeTagRow(for tag: Tag) -> TagRow {
        TagRow(
            tag: tag,
            titleLineLimit: viewModel.getTitleLineLimit(),
            titleFontSize: viewModel.getTitleFontSize(),
            titleLineSpacing: viewModel.getTitleLineSpacing(),
            showColorString: true,
            showInfo: viewModel.getShowInfo(),
            showTagCount: true
        )
    }

    private func activeRow(for tag: Tag) -> some View {
        Button {
            viewModel.onTapRowInEditMode(tag)
        } label: {
            makeTagRow(for: tag)
        }
        .foregroundStyle(.primary)
        .contentShape(Rectangle())
        .listRowInsets(.init())
        .moveDisabled(false)
        .listRowBackground(
            Color(uiColor: .secondarySystemGroupedBackground)
        )
    }

    private func inactiveRow(for tag: Tag) -> some View {
        makeTagRow(for: tag)
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.onTapRowInNormalMode(tag)
            }
            .contextMenu {
                Button("Preview", systemImage: "eye") {
                    viewModel.onTapPreview(tag)
                }
            }
            .listRowInsets(.init())
            .moveDisabled(true)
            .listRowBackground(
                Color(
                    uiColor: tag == viewModel.selectedTag
                        ? .quaternaryLabel
                        : .systemBackground
                )
            )
    }
}

@MainActor
private func makeTagFetchFailurePreview() -> AnyView {
    do {
        let container = try ModelContainer(
            for: Memo.self,
            Tag.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let repository = TagRepository(modelContext: container.mainContext)
        try repository.add(
            Tag(title: "Test Tag", color: "#FF0000")
        )

        var shouldFail = true
        let viewModel = TagsViewModel(
            tagRepository: repository,
            userDefaultsRepository: UserDefaultsRepository(),
            fetchTagsHandler: {
                if shouldFail {
                    shouldFail = false
                    throw NSError(
                        domain: "Preview",
                        code: 1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Simulated fetch failure"
                        ]
                    )
                }
                return try repository.tags()
            }
        )

        return AnyView(
            NavigationStack {
                TagsView(
                    editMode: .constant(.inactive),
                    selectedTag: .constant(nil),
                    viewModel: viewModel
                )
            }
            .modelContainer(container)
        )
    }
    catch {
        return AnyView(
            Text("Preview setup failed: \(error.localizedDescription)")
        )
    }
}

#Preview("Tag fetch failure") {
    makeTagFetchFailurePreview()
}
