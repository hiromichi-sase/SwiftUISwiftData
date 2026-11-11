//
//  FilterMemosView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/21.
//

import SwiftData
import SwiftUI

struct FilterMemosView: View {
    enum AlertType: Identifiable {
        case reset
        var id: AlertType { self }
    }

    /// ビューの状態を管理するViewModel。
    @State
    private var viewModel: FilterMemosViewModel
    /// ビューを閉じるための環境変数。
    @Environment(\.dismiss)
    private var dismiss
    @Binding
    private var isFiltering: Bool
    @Binding
    private var title: String
    @State
    private var titleToStore: String
    @Binding
    private var tagsForFiltering: [Tag]
    @Binding
    private var selectedMemo: Memo?
    @State
    private var selectedTags: [Tag] = []
    @FocusState
    private var textFieldFocus: Bool
    @State
    private var currentAlert: AlertType?
    @State
    private var showSelectTagView = false
    /// ナビゲーションパスの状態変数。
    @State
    private var path = NavigationPath()

    init(
        isFiltering: Binding<Bool>,
        title: Binding<String>,
        tagsForFiltering: Binding<[Tag]>,
        selectedMemo: Binding<Memo?>,
    ) {
        _isFiltering = isFiltering
        _title = title
        _titleToStore = State(initialValue: title.wrappedValue)
        _tagsForFiltering = tagsForFiltering
        _selectedTags = State(initialValue: tagsForFiltering.wrappedValue)
        _selectedMemo = selectedMemo

        _viewModel = State(
            wrappedValue: FilterMemosViewModel(
                tagRepository: TagRepository(modelContext: ModelContainerManager.shared.modelContainer.mainContext),
                userDefaultsRepository: UserDefaultsRepository()
            )
        )
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading) {
                    CustomTextField(
                        text: $titleToStore,
                        focus: _textFieldFocus,
                        placeholder: "Divide Keywords By Space",
                        background: Color(uiColor: .secondarySystemBackground),
                        submitLabel: .done,
                        submitButtonTapped: nil
                    )
                    .padding(.bottom, 8)
                    HStack(spacing: 12) {
                        Text(viewModel.tags.isEmpty ? "No Tags" : "Select Tags")
                        Button {
                            showSelectTagView = true
                        } label: {
                            Image(systemName: selectedTags.isEmpty ? "tag" : "tag.fill")
                                .font(.system(size: 24))
                                .tint(.primary)
                        }
                        .disabled(viewModel.tags.isEmpty)
                    }
                    Spacer()
                }
            }
            .padding(.top, .zero)
            .padding(.horizontal)
            .padding(.bottom, 8)
            .onLoad {
                textFieldFocus = true
            }
            .alert(item: $currentAlert) { alertType in
                switch alertType {
                    case .reset:
                        resetAlert
                }
            }
            .navigationTitle("Filter Memos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(uiColor: .systemBackground), for: .navigationBar)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    toolbarItemTopBarLeading
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    toolbarItemTopBarTrailing
                }
            }
            .navigationDestination(isPresented: $showSelectTagView) {
                SelectTagView(selectedTags: $selectedTags)
            }
        }
    }

    @ViewBuilder
    private var toolbarItemTopBarLeading: some View {
        Button("Close", systemImage: "xmark") {
            dismiss()
        }
    }

    @ViewBuilder
    private var toolbarItemTopBarTrailing: some View {
        Button("Reset", systemImage: "xmark.circle.fill") {
            currentAlert = .reset
        }
        .disabled(!isFiltering)
        .keyboardShortcut("r", modifiers: [.command])
        Button("Save", systemImage: "checkmark") {
            saveFiltering()
        }
        .disabled(saveButtonDisabled)
        .keyboardShortcut("s", modifiers: [.command])
    }

    private var saveButtonDisabled: Bool {
        viewModel.saveButtonDisabled(
            originalTitle: title,
            editingTitle: titleToStore,
            originalTags: tagsForFiltering,
            editingTags: selectedTags
        )
    }

    private func saveFiltering() {
        title = titleToStore
        tagsForFiltering = selectedTags
        isFiltering = viewModel.hasFilteringCondition(
            title: titleToStore,
            tags: selectedTags
        )
        dismiss()
    }

    private func resetFiltering() {
        isFiltering = false
        title = ""
        tagsForFiltering = []
        selectedMemo = nil
        dismiss()
    }

    private var resetAlert: Alert {
        Alert(
            title: Text("Reset filtering?"),
            primaryButton: .destructive(Text("Reset")) {
                resetFiltering()
            },
            secondaryButton: .cancel()
        )
    }
}

#Preview {
    NavigationStack {
        FilterMemosView(
            isFiltering: .constant(false),
            title: .constant(""),
            tagsForFiltering: .constant([]),
            selectedMemo: .constant(nil),
        )
    }
}
