//
//  EditTagView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import SwiftData
import SwiftUI

/// タグの内容を編集するビュー。
struct EditTagView: View {
    @State
    private var viewModel: EditTagViewModel

    @Environment(\.dismiss)
    private var dismiss

    @FocusState
    private var textFieldFocus: Bool

    @State
    private var color: Color = .clear

    @State
    private var path = NavigationPath()

    /// - Parameter tag: 編集するタグ（デフォルトはnilで新規作成）
    init(tag: Tag? = nil) {
        let vm = EditTagViewModel(
            tag: tag,
            tagRepository: TagRepository(modelContext: ModelContainerManager.shared.modelContainer.mainContext),
            userDefaultsRepository: UserDefaultsRepository()
        )
        _viewModel = State(wrappedValue: vm)
        _color = State(initialValue: vm.colorString.color())
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 4) {
                CustomTextField(
                    text: $viewModel.title,
                    focus: _textFieldFocus,
                    placeholder: "Input Title",
                    background: Color(uiColor: .secondarySystemBackground),
                    submitLabel: .done,
                    submitButtonTapped: nil
                )
                .padding(.bottom, 20)

                HStack {
                    ColorPicker(selection: $color, supportsOpacity: false) {
                        HStack {
                            Text("Select Color")
                            Image(systemName: "paintpalette")
                        }
                    }
                    .onChange(of: color) {
                        viewModel.colorString = color.hexString()
                    }
                    .frame(width: 170)

                    Spacer()

                    TagColorView(
                        colorString: viewModel.colorString,
                        showColorString: true
                    )
                }

                Spacer()

                if viewModel.showInfo, let tag = viewModel.tag {
                    InfoText.dateView(for: tag)
                }
            }
            .padding(.top, .zero)
            .padding(.horizontal)
            .padding(.bottom, 8)
            .onAppear {
                textFieldFocus = true
                color = viewModel.colorString.color()
            }
            .onChange(of: viewModel.shouldDismiss) {
                if viewModel.shouldDismiss {
                    dismiss()
                }
            }
            .alert(item: $viewModel.currentAlert) { alertType in
                switch alertType {
                    case .close:
                        Alert(
                            title: Text("Close without saving?"),
                            primaryButton: .destructive(Text("Close")) {
                                viewModel.onConfirmClose()
                            },
                            secondaryButton: .cancel()
                        )
                    case .error:
                        Alert(
                            title: Text("The Error occured."),
                            message: Text(viewModel.errorMessage),
                            dismissButton: .default(Text("OK"))
                        )
                }
            }
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(uiColor: .systemBackground), for: .navigationBar)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Close", systemImage: "xmark") {
                        viewModel.onTapClose()
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Save", systemImage: "checkmark.circle.fill") {
                        viewModel.saveTag()
                    }
                    .disabled(!viewModel.canSave)
                    .keyboardShortcut("s", modifiers: [.command])
                }
            }
            .toast(message: $viewModel.toastMessage)
        }
    }
}

#Preview {
    NavigationStack {
        let tag = Tag(title: "Sample Title", color: "#000000", createdAt: Date(), updatedAt: Date(), order: .zero)
        EditTagView(tag: tag)
    }
}
