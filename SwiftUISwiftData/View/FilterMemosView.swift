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
    @State
    var selectedTags: [Tag] = []
    @FocusState
    private var textFieldFocus: Bool
    @State
    private var currentAlert: AlertType?
    /// ナビゲーションパスの状態変数。
    @State
    var path = NavigationPath()

    init(isFiltering: Binding<Bool>, title: Binding<String>) {
        _isFiltering = isFiltering
        _title = title
        _titleToStore = State(initialValue: title.wrappedValue)
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 4) {
                CustomTextField(
                    text: $titleToStore,
                    focus: _textFieldFocus,
                    placeholder: "Input keywords to search by title",
                    background: Color(uiColor: .secondarySystemBackground),
                    submitLabel: .done,
                    icon: .none,
                    submitButtonTapped: nil
                )
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
        .disabled(title.isEmpty)
        .keyboardShortcut("r", modifiers: [.command])
        Button("Save", systemImage: "checkmark") {
            isFiltering = true
            title = titleToStore
            dismiss()
        }
        .disabled(title == titleToStore)
        .keyboardShortcut("s", modifiers: [.command])
    }

    private var resetAlert: Alert {
        Alert(
            title: Text("Reset filtering?"),
            primaryButton: .destructive(Text("Close")) {
                isFiltering = false
                title = ""
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
            title: .constant("")
        )
    }
}
