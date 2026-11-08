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
    var selectedTags: [Tag]
    @State
    var editMode: EditMode = .active
    @State
    private var selection: Set<UUID> = []
    @State
    private var isPresentedModally = false
    @State
    var path = NavigationPath()

    init(selectedTags: Binding<[Tag]>) {
        _selectedTags = selectedTags
        _viewModel = State(
            wrappedValue: SelectTagViewModel(
                tagRepository: TagRepository(modelContext: ModelContainerManager.shared.modelContainer.mainContext),
                userDefaultsRepository: UserDefaultsRepository()
            )
        )
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
        .listRowBackground(Color(uiColor: .secondarySystemGroupedBackground))
    }

    private func setupOnAppear() {
        if selection.isEmpty {
            selection = viewModel.selectedIDs(from: selectedTags)
        }
        isPresentedModally = _isPresented.wrappedValue
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
