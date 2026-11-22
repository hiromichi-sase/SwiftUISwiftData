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

    @State
    private var viewModel: FilterMemosViewModel
    @Environment(\.dismiss)
    private var dismiss
    @Binding
    private var isFiltering: Bool
    @Binding
    private var title: String
    @Binding
    private var tagsForFiltering: [Tag]
    @Binding
    private var selectedMemo: Memo?
    @FocusState
    private var textFieldFocus: Bool
    @State
    private var currentAlert: AlertType?
    @State
    private var showSelectTagView = false
    @State
    private var didInitializeFilter = false
    @State
    private var path = NavigationPath()

    /// 通常の依存関係を使用してビューを生成する。
    init(
        isFiltering: Binding<Bool>,
        title: Binding<String>,
        tagsForFiltering: Binding<[Tag]>,
        selectedMemo: Binding<Memo?>
    ) {
        self.init(
            isFiltering: isFiltering,
            title: title,
            tagsForFiltering: tagsForFiltering,
            selectedMemo: selectedMemo,
            tagRepository: TagRepository(
                modelContext: ModelContainerManager.shared.modelContainer.mainContext
            ),
            userDefaultsRepository: UserDefaultsRepository()
        )
    }

    /// 外部から Repository を注入してビューを生成する。
    init(
        isFiltering: Binding<Bool>,
        title: Binding<String>,
        tagsForFiltering: Binding<[Tag]>,
        selectedMemo: Binding<Memo?>,
        tagRepository: TagRepository,
        userDefaultsRepository: UserDefaultsRepository
    ) {
        self.init(
            isFiltering: isFiltering,
            title: title,
            tagsForFiltering: tagsForFiltering,
            selectedMemo: selectedMemo,
            viewModel: FilterMemosViewModel(
                tagRepository: tagRepository,
                userDefaultsRepository: userDefaultsRepository
            )
        )
    }

    /// 外部で生成した ViewModel を使用する。
    init(
        isFiltering: Binding<Bool>,
        title: Binding<String>,
        tagsForFiltering: Binding<[Tag]>,
        selectedMemo: Binding<Memo?>,
        viewModel: FilterMemosViewModel
    ) {
        _isFiltering = isFiltering
        _title = title
        _tagsForFiltering = tagsForFiltering
        _selectedMemo = selectedMemo
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading) {
                    CustomTextField(
                        text: $viewModel.editingTitle,
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
                            Image(
                                systemName: viewModel.editingTags.isEmpty
                                    ? "tag"
                                    : "tag.fill"
                            )
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
            .onAppear {
                initializeFilterIfNeeded()
            }
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
            .toolbarBackground(
                Color(uiColor: .systemBackground),
                for: .navigationBar
            )
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    toolbarItemTopBarLeading
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    toolbarItemTopBarTrailing
                }
            }
            .navigationDestination(isPresented: $showSelectTagView) {
                SelectTagView(
                    selectedTags: $viewModel.editingTags,
                    viewModel: viewModel.makeSelectTagViewModel()
                )
            }
        }
    }

    /// 初回表示時に親のフィルター条件を編集値へ取り込む。
    private func initializeFilterIfNeeded() {
        guard !didInitializeFilter else { return }

        viewModel.setInitialFilter(
            title: title,
            tags: tagsForFiltering
        )
        didInitializeFilter = true
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
        .disabled(viewModel.saveButtonDisabled)
        .keyboardShortcut("s", modifiers: [.command])
    }

    private func saveFiltering() {
        let result = viewModel.buildSaveResult()
        isFiltering = result.isFiltering
        title = result.title
        tagsForFiltering = result.tags
        selectedMemo = result.selectedMemo
        dismiss()
    }

    private func resetFiltering() {
        let result = viewModel.buildResetResult()
        isFiltering = result.isFiltering
        title = result.title
        tagsForFiltering = result.tags
        selectedMemo = result.selectedMemo
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
    FilterMemosView(
        isFiltering: .constant(false),
        title: .constant(""),
        tagsForFiltering: .constant([]),
        selectedMemo: .constant(nil)
    )
}
