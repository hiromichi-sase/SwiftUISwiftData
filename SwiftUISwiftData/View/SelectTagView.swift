//
//  SelectTagView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import SwiftData
import SwiftUI

struct SelectTagView: View {
    /// ビューの状態を管理するViewModel。
    @ObservedObject
    var viewModel = SelectTagViewModel(
        tagRepository: TagRepository(modelContainer: ModelContainerManager.shared.modelContainer),
        userDefaultsRepository: UserDefaultsRepository()
    )

    @Environment(\.isPresented)
    private var isPresented
    /// ビューを閉じるための環境変数。
    @Environment(\.dismiss)
    private var dismiss
    @Binding
    var selectedTags: [Tag]
    /// 編集モードの状態を管理する状態変数。
    @State
    var editMode: EditMode = .active
    /// 複数選択されたタグのIDを保持する状態変数。
    @State
    private var selection: Set<UUID> = []
    @State
    private var isPresentedModally = false
    /// ナビゲーションパスの状態変数。
    @State
    var path = NavigationPath()

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
                if selection.isEmpty {
                    selection = Set(selectedTags.map { $0.id })
                }
                isPresentedModally = _isPresented.wrappedValue
            }
        }
    }

    private func activeRow(for tag: Tag) -> some View {
        Button {
            if selection.contains(tag.id) {
                selection.remove(tag.id)
            }
            else {
                selection.insert(tag.id)
            }
        } label: {
            SelectTagActiveRow(
                tag: tag,
                titleLineLimit: viewModel.getTitleLineLimit(),
                titleFontSize: viewModel.getTitleFontSize(),
                titleLineSpacing: viewModel.getTitleLineSpacing(),
            )
        }
        .foregroundStyle(.primary)
        .padding()
        .contentShape(Rectangle())
        .listRowInsets(.init())
        .moveDisabled(false)
        .listRowBackground(Color(uiColor: .secondarySystemGroupedBackground))
    }

    /// ツールバーの左側のアイテムを定義するビュー。
    ///
    /// 変更がある場合は確認アラートを表示し、変更がない場合はビューを閉じる。
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
            selectedTags = tagsForSelection
            dismiss()
        }
        .disabled(selectedTags == tagsForSelection)
        .keyboardShortcut("s", modifiers: [.command])
    }

    private var tagsForSelection: [Tag] {
        viewModel.tags.filter { selection.contains($0.id) }
    }
}
