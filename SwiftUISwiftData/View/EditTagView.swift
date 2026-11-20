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
    private var color: Color

    @State
    private var path = NavigationPath()

    /// 通常の依存関係を使用してビューを生成する。
    ///
    /// - Parameter tag: 編集するタグ。nil の場合は新規作成。
    init(tag: Tag? = nil) {
        self.init(
            tag: tag,
            tagRepository: TagRepository(
                modelContext: ModelContainerManager.shared.modelContainer.mainContext
            ),
            userDefaultsRepository: UserDefaultsRepository()
        )
    }

    /// 外部から Repository を注入してビューを生成する。
    init(
        tag: Tag? = nil,
        tagRepository: any TagRepositoryProtocol,
        userDefaultsRepository: any UserDefaultsRepositoryProtocol
    ) {
        self.init(
            viewModel: EditTagViewModel(
                tag: tag,
                tagRepository: tagRepository,
                userDefaultsRepository: userDefaultsRepository
            )
        )
    }

    /// 外部で生成した ViewModel を使用する。
    init(viewModel: EditTagViewModel) {
        _viewModel = State(initialValue: viewModel)
        _color = State(initialValue: viewModel.colorString.color())
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
            .toolbarBackground(
                Color(uiColor: .systemBackground),
                for: .navigationBar
            )
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
    let tag = Tag(
        title: "Sample Title",
        color: "#000000",
        createdAt: Date(),
        updatedAt: Date(),
        order: .zero
    )

    EditTagView(tag: tag)
}
