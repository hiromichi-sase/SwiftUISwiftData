//
//  EditMemoView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/05/04.
//

import SwiftData
import SwiftUI

struct EditMemoView: View {
    @State
    private var viewModel: EditMemoViewModel

    @Environment(\.dismiss)
    private var dismiss
    @FocusState
    private var textEditorFocus: Bool
    @State
    private var textSelection: TextSelection?
    @FocusState
    private var inputViewFocus: Bool
    @State
    private var path = NavigationPath()

    /// 通常の依存関係を使用してビューを生成する。
    ///
    /// - Parameter memo: 編集するメモ。nil の場合は新規作成。
    init(memo: Memo? = nil) {
        let modelContext = ModelContainerManager.shared.modelContainer.mainContext

        self.init(
            memo: memo,
            memoRepository: MemoRepository(modelContext: modelContext),
            tagRepository: TagRepository(modelContext: modelContext),
            userDefaultsRepository: UserDefaultsRepository()
        )
    }

    /// 外部から Repository を注入してビューを生成する。
    init(
        memo: Memo? = nil,
        memoRepository: MemoRepository,
        tagRepository: TagRepository,
        userDefaultsRepository: UserDefaultsRepository
    ) {
        self.init(
            viewModel: EditMemoViewModel(
                memo: memo,
                memoRepository: memoRepository,
                tagRepository: tagRepository,
                userDefaultsRepository: userDefaultsRepository
            )
        )
    }

    /// 外部で生成した ViewModel を使用する。
    init(viewModel: EditMemoViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 4) {
                if viewModel.showTitleView {
                    InputView(
                        text: $viewModel.titleToStore,
                        focus: _inputViewFocus,
                        placeholder: "Input title",
                        textFieldBackground: Color(uiColor: .secondarySystemBackground),
                        submitLabel: .done,
                        submitButtonTapped: { viewModel.submitRename() },
                        cancelButtonTapped: { viewModel.cancelRename() }
                    )
                    .padding(.bottom, 4)
                }

                contentView

                if viewModel.getShowInfo(), !viewModel.showTitleView {
                    VStack(alignment: .leading, spacing: .zero) {
                        InfoText.countView(
                            content: viewModel.content,
                            textSelection: textSelection
                        )
                        if let memo = viewModel.memo {
                            InfoText.dateView(for: memo)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            .onAppear {
                textEditorFocus = true
                DispatchQueue.main.async {
                    textSelection = .init(
                        insertionPoint: viewModel.content.startIndex
                    )
                }
            }
            .alert(item: $viewModel.currentAlert) { alertType in
                switch alertType {
                    case .close:
                        Alert(
                            title: Text("Close without saving?"),
                            primaryButton: .destructive(Text("Close")) {
                                dismiss()
                            },
                            secondaryButton: .cancel()
                        )

                    case .error:
                        Alert(
                            title: Text("The Error occured."),
                            message: Text(
                                viewModel.error?.localizedDescription ?? ""
                            ),
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
                        if viewModel.memoUpdated {
                            viewModel.currentAlert = .close
                        }
                        else {
                            dismiss()
                        }
                    }
                    .disabled(viewModel.showTitleView)

                    Button(
                        "Tag",
                        systemImage: viewModel.selectedTags.isEmpty
                            ? "tag"
                            : "tag.fill"
                    ) {
                        viewModel.onTapTag()
                    }
                    .disabled(!viewModel.canOpenTagSelector)
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(
                        "Rename",
                        systemImage: "rectangle.and.pencil.and.ellipsis"
                    ) {
                        viewModel.onTapRename()
                        DispatchQueue.main.async {
                            inputViewFocus = true
                        }
                    }
                    .disabled(viewModel.showTitleView)
                    .keyboardShortcut("t", modifiers: [.command])

                    Button("Save", systemImage: "checkmark.circle.fill") {
                        viewModel.save()
                    }
                    .disabled(!viewModel.canSave)
                    .keyboardShortcut("s", modifiers: [.command])
                }
            }
            .toast(message: $viewModel.toastMessage)
            .sheet(isPresented: $viewModel.showSelectTagView) {
                SelectTagView(selectedTags: $viewModel.selectedTags)
                    .interactiveDismissDisabled(true)
            }
            .onReceive(
                NotificationCenter.default.publisher(
                    for: .closeAllPresentedViewsFromShortcut
                )
            ) { _ in
                viewModel.onReceiveCloseAllPresentedViews()
                textEditorFocus = false
                inputViewFocus = false
            }
        }
    }

    private var contentView: some View {
        TextEditor(
            text: $viewModel.content,
            selection: $textSelection
        )
        .disabled(viewModel.showTitleView)
        .foregroundStyle(
            viewModel.showTitleView
                ? Color(UIColor.quaternaryLabel)
                : .primary
        )
        .font(.system(size: CGFloat(viewModel.getContentFontSize())))
        .lineSpacing(CGFloat(viewModel.getContentLineSpacing()))
        .border(
            viewModel.showTitleView
                ? Color(UIColor.quaternaryLabel)
                : .primary
        )
        .focused($textEditorFocus)
        .overlay(alignment: .topLeading) {
            if viewModel.content.isEmpty && !viewModel.showTitleView {
                Text("Input Content")
                    .font(.system(size: CGFloat(viewModel.getContentFontSize())))
                    .allowsHitTesting(false)
                    .foregroundColor(Color(uiColor: .placeholderText))
                    .padding(6)
            }
        }
    }
}

#Preview {
    let memo = Memo(
        title: "Sample Title",
        content: "Sample Content",
        createdAt: Date(),
        updatedAt: Date(),
        order: .zero
    )
    EditMemoView(memo: memo)
}
