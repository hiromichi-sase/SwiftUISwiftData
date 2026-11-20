//
//  SelectTagView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import SwiftData
import SwiftUI

struct SelectTagView: View {
    @State
    private var viewModel: SelectTagViewModel

    @Environment(\.isPresented)
    private var isPresented
    @Environment(\.dismiss)
    private var dismiss
    @Binding
    private var selectedTags: [Tag]
    @State
    private var editMode: EditMode = .active
    @State
    private var selection: Set<UUID> = []
    @State
    private var isPresentedModally = false
    @State
    private var didInitializeSelection = false
    @State
    private var path = NavigationPath()

    /// 通常の依存関係を使用してビューを生成する。
    init(selectedTags: Binding<[Tag]>) {
        self.init(
            selectedTags: selectedTags,
            tagRepository: TagRepository(
                modelContext: ModelContainerManager.shared.modelContainer.mainContext
            ),
            userDefaultsRepository: UserDefaultsRepository()
        )
    }

    /// 外部から Repository を注入してビューを生成する。
    init(
        selectedTags: Binding<[Tag]>,
        tagRepository: TagRepository,
        userDefaultsRepository: UserDefaultsRepository
    ) {
        self.init(
            selectedTags: selectedTags,
            viewModel: SelectTagViewModel(
                tagRepository: tagRepository,
                userDefaultsRepository: userDefaultsRepository
            )
        )
    }

    /// 外部で生成した ViewModel を使用する。
    init(
        selectedTags: Binding<[Tag]>,
        viewModel: SelectTagViewModel
    ) {
        _selectedTags = selectedTags
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                List(selection: $selection) {
                    ForEach(viewModel.tags) { tag in
                        activeRow(for: tag)
                            .id(tag.id)
                            .tag(tag.id)
                    }
                }
                .navigationTitle("Select Tag")
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
            }
            .onAppear {
                setupOnAppear()
            }
        }
    }

    private func activeRow(for tag: Tag) -> some View {
        Button {
            viewModel.toggleSelection(&selection, for: tag.id)
        } label: {
            TagRow(
                tag: tag,
                titleLineLimit: viewModel.titleLineLimit,
                titleFontSize: viewModel.titleFontSize,
                titleLineSpacing: viewModel.titleLineSpacing,
                showColorString: false
            )
        }
        .foregroundStyle(.primary)
        .contentShape(Rectangle())
        .listRowInsets(.init())
        .moveDisabled(false)
        .listRowBackground(
            Color(uiColor: .secondarySystemGroupedBackground)
        )
    }

    private func setupOnAppear() {
        if !didInitializeSelection {
            selection = viewModel.selectedIDs(from: selectedTags)
            didInitializeSelection = true
        }
        isPresentedModally = isPresented
    }

    @ViewBuilder
    private var toolbarItemTopBarLeading: some View {
        if isPresentedModally {
            Button("Close", systemImage: "xmark") {
                dismiss()
            }
        }
    }

    @ViewBuilder
    private var toolbarItemTopBarTrailing: some View {
        Button("Save", systemImage: "checkmark") {
            selectedTags = viewModel.selectedTags(from: selection)
            dismiss()
        }
        .disabled(selection == selectedTagIDs)
        .keyboardShortcut("s", modifiers: [.command])
    }

    private var selectedTagIDs: Set<UUID> {
        Set(selectedTags.map(\.id))
    }
}
