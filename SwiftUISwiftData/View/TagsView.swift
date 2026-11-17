//
//  TagsView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import SwiftData
import SwiftUI

struct TagsView: View {
    @StateObject
    var viewModel: TagsViewModel
    @State
    var scrollViewProxy: ScrollViewProxy?
    @State
    private var didSyncInitialExternalState = false
    @Binding
    var editMode: EditMode
    @Binding
    var selectedTag: Tag?

    init(
        editMode: Binding<EditMode>,
        selectedTag: Binding<Tag?>
    ) {
        _editMode = editMode
        _selectedTag = selectedTag
        _viewModel = StateObject(
            wrappedValue: TagsViewModel(
                tagRepository: TagRepository(
                    modelContext: ModelContainerManager.shared.modelContainer.mainContext
                ),
                userDefaultsRepository: UserDefaultsRepository()
            )
        )
    }

    var body: some View {
        VStack(spacing: 8.0) {
            list
                .onAppear {
                    guard !didSyncInitialExternalState else { return }
                    didSyncInitialExternalState = true
                    viewModel.editMode = editMode
                    viewModel.selectedTag = selectedTag
                }
                .onChange(of: viewModel.editMode) { _, newValue in
                    editMode = newValue
                }
                .onChange(of: viewModel.selectedTag) { _, newValue in
                    selectedTag = newValue
                }
                .onChange(of: viewModel.tags) { oldTags, newTags in
                    viewModel.onTagsChanged(oldTags: oldTags, newTags: newTags)
                    if let id = viewModel.consumeScrollTargetID(),
                        let proxy = scrollViewProxy
                    {
                        var transaction = Transaction()
                        transaction.disablesAnimations = true
                        withTransaction(transaction) {
                            proxy.scrollTo(id, anchor: .center)
                        }
                    }
                }
                .alert(item: $viewModel.currentAlert) { alertType in
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
                                message: Text(viewModel.error?.localizedDescription ?? "Unknown error"),
                                dismissButton: .default(Text("OK"))
                            )
                    }
                }
                .navigationTitle(viewModel.navigationTitle)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(viewModel.editMode.isEditing)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        toolbarTopTrailing
                    }
                    ToolbarItemGroup(placement: .bottomBar) {
                        toolbarBottomBar
                    }
                }
                .environment(\.editMode, $viewModel.editMode)
                .sheet(isPresented: $viewModel.showingAddTag) {
                    EditTagView()
                        .interactiveDismissDisabled(true)
                }
                .onReceive(NotificationCenter.default.publisher(for: .closeAllPresentedViewsFromShortcut)) { _ in
                    viewModel.onCloseAllPresentedViews()
                }
                .toast(message: $viewModel.toastMessage)
        }
    }

    private var list: some View {
        ScrollViewReader { proxy in
            VStack {
                if viewModel.editMode.isEditing {
                    List(selection: $viewModel.selection) {
                        ForEach(viewModel.tags) { tag in
                            activeRow(for: tag)
                                .id(tag.id)
                                .tag(tag.id)
                        }
                        .onMove(perform: viewModel.moveTag)
                    }
                }
                else {
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
                                        view.swipeActions(edge: .leading, allowsFullSwipe: false) {
                                            Button("Copy", systemImage: "doc.on.doc") {
                                                UIPasteboard.general.string = tag.title
                                            }
                                            .tint(.green)
                                        }
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button("Delete", systemImage: "trash", role: .destructive) {
                                            viewModel.onTapDelete(tag: tag)
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

    @ViewBuilder
    private var toolbarTopTrailing: some View {
        if viewModel.editMode.isEditing {
            Button("Done", systemImage: "checkmark") {
                viewModel.onTapDone()
            }
            .keyboardShortcut(.cancelAction)
        }
        else if !viewModel.tags.isEmpty {
            Button("Edit", systemImage: "pencil") {
                viewModel.onTapEdit()
            }
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

            GlassMenu(imageSystemName: "circle.grid.2x2.topleft.checkmark.filled") {
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
        .listRowBackground(Color(uiColor: .secondarySystemGroupedBackground))
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
                Color(uiColor: tag == viewModel.selectedTag ? .quaternaryLabel : .systemBackground)
            )
    }
}
