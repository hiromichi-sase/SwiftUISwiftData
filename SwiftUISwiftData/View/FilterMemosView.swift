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
    @ObservedObject
    var viewModel = FilterMemosViewModel(
        tagRepository: TagRepository(modelContainer: ModelContainerManager.shared.modelContainer),
    )
    /// ビューを閉じるための環境変数。
    @Environment(\.dismiss)
    private var dismiss
    @Binding
    private var isFiltering: Bool
    /// タイトルの状態変数。
    @Binding
    private var title: String
    @State
    private var titleToStore: String
    @Binding
    private var tagsForFiltering: [Tag]
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
    var path = NavigationPath()

    init(isFiltering: Binding<Bool>, title: Binding<String>, tagsForFiltering: Binding<[Tag]>) {
        _isFiltering = isFiltering
        _title = title
        _titleToStore = State(initialValue: title.wrappedValue)
        _tagsForFiltering = tagsForFiltering
        _selectedTags = State(initialValue: tagsForFiltering.wrappedValue)
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading) {
                CustomTextField(
                    text: $titleToStore,
                    focus: _textFieldFocus,
                    placeholder: "Input keywords to search by title",
                    background: Color(uiColor: .secondarySystemBackground),
                    submitLabel: .done,
                    icon: .none,
                    submitButtonTapped: nil
                )
                .padding(.bottom, 20)
                HStack {
                    Text("Select Tag")
                    Button {
                        showSelectTagView = true
                    } label: {
                        Image(systemName: selectedTags.isEmpty ? "tag" : "tag.fill")
                    }
                }
                Spacer()
            }
            .padding(.top, .zero)
            .padding(.horizontal)
            .padding(.bottom, 8)
            .onAppear {
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
        .disabled(title.isEmpty && tagsForFiltering.isEmpty)
        .keyboardShortcut("r", modifiers: [.command])
        Button("Save", systemImage: "checkmark") {
            isFiltering = true
            title = titleToStore
            tagsForFiltering = selectedTags
            dismiss()
        }
        .disabled(title == titleToStore && tagsForFiltering.sortedByOrder == selectedTags.sortedByOrder)
        .keyboardShortcut("s", modifiers: [.command])
    }

    private var resetAlert: Alert {
        Alert(
            title: Text("Reset filtering?"),
            primaryButton: .destructive(Text("Close")) {
                isFiltering = false
                title = ""
                tagsForFiltering = []
                dismiss()
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
            tagsForFiltering: .constant([])
        )
    }
}
