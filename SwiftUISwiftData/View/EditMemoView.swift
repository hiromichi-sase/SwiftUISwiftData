//
//  EditMemoView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/05/04.
//

import SwiftData
import SwiftUI

/// メモの内容を編集するビュー。
struct EditMemoView: View {
    enum AlertType: Identifiable {
        case close
        case error
        var id: AlertType { self }
    }

    /// ビューモデルの状態変数。
    @ObservedObject
    var viewModel = EditMemoViewModel(
        memoRepository: MemoRepository(modelContainer: ModelContainerManager.shared.modelContainer),
        tagRepository: TagRepository(modelContainer: ModelContainerManager.shared.modelContainer),
        userDefaultsRepository: UserDefaultsRepository()
    )
    /// ビューを閉じるための環境変数。
    @Environment(\.dismiss)
    private var dismiss
    /// 編集中のメモ。
    @State
    private var memo: Memo?
    /// タイトルと内容の状態変数。
    @State
    private var title: String
    /// 内容の状態変数。
    @State
    private var content: String
    /// タイトル編集ビューを表示するフラグ。
    @State
    private var showTitleView = false
    /// トーストメッセージの状態変数。
    @State
    private var toastMessage = ""
    /// テキストエディターのフォーカス状態。
    @FocusState
    private var textEditorFocus: Bool
    @State
    private var textSelection: TextSelection?
    /// テキストフィールドのフォーカス状態。
    @FocusState
    private var textFieldFocus: Bool
    @State
    private var error: Error?
    @State
    private var currentAlert: AlertType?
    @FocusState
    private var inputViewFocus: Bool
    @State
    private var showSelectTagView = false
    @State
    private var tags: [Tag]
    /// ナビゲーションパスの状態変数。
    @State
    var path = NavigationPath()

    /// イニシャライザ。
    /// - Parameter memo: 編集するメモ（デフォルトはnilで新規作成）
    init(memo: Memo? = nil) {
        self.memo = memo
        _title = State(initialValue: memo?.title ?? "")
        _content = State(initialValue: memo?.content ?? "")
        tags = memo?.tags ?? []
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 4) {
                if showTitleView {
                    InputView(
                        text: $title,
                        focus: _inputViewFocus,
                        placeholder: "Input title",
                        textFieldBackground: Color(uiColor: .secondarySystemBackground),
                        submitLabel: .done,
                        icon: .none,
                        submitButtonTapped: {
                            showTitleView = false
                        },
                        cancelButtonTapped: {
                            showTitleView = false
                            title = memo?.title ?? ""
                        }
                    )
                    .padding(.bottom, 4)
                }
                contentView
                if viewModel.getShowInfo(), !showTitleView {
                    VStack(alignment: .leading, spacing: .zero) {
                        InfoText.countView(content: content, textSelection: textSelection)
                        if let memo {
                            InfoText.dateView(for: memo)
                        }
                    }
                }
            }
            .padding(.top, .zero)
            .padding(.horizontal)
            .padding(.bottom, 8)
            .onAppear {
                textEditorFocus = true
                DispatchQueue.main.async {
                    textSelection = .init(insertionPoint: content.startIndex)
                }
            }
            .alert(item: $currentAlert) { alertType in
                switch alertType {
                    case .close:
                        closeAlert
                    case .error:
                        errorAlert
                }
            }
            .navigationTitle(title)
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
            .toast(message: $toastMessage)
            .sheet(isPresented: $showSelectTagView) {
                SelectTagView(selectedTags: $tags)
                    .interactiveDismissDisabled(true)
            }
        }
    }

    /// 内容編集ビュー。
    private var contentView: some View {
        TextEditor(text: $content, selection: $textSelection)
            .disabled(showTitleView)
            .foregroundStyle(showTitleView ? Color(UIColor.quaternaryLabel) : .primary)
            .font(.system(size: CGFloat(viewModel.getContentFontSize())))
            .lineSpacing(CGFloat(viewModel.getContentLineSpacing()))
            .border(showTitleView ? Color(UIColor.quaternaryLabel) : .primary)
            .focused($textEditorFocus)
            .overlay(alignment: .topLeading) {
                if content.isEmpty && !showTitleView {
                    Text("Input Content")
                        .font(.system(size: CGFloat(viewModel.getContentFontSize())))
                        .allowsHitTesting(false)
                        .foregroundColor(Color(uiColor: .placeholderText))
                        .padding(6)
                }
            }
    }

    private var closeAlert: Alert {
        Alert(
            title: Text("Close without saving?"),
            primaryButton: .destructive(Text("Close")) {
                dismiss()
            },
            secondaryButton: .cancel()
        )
    }

    private var errorAlert: Alert {
        .init(
            title: Text("The Error occured."),
            message: Text(error?.localizedDescription ?? ""),
            dismissButton: .default(Text("OK"))
        )
    }

    /// ツールバーの左側のアイテムを定義するビュー。
    ///
    /// 変更がある場合は確認アラートを表示し、変更がない場合はビューを閉じる。
    @ViewBuilder
    private var toolbarItemTopBarLeading: some View {
        Button("Close", systemImage: "xmark") {
            if memoUpdated {
                currentAlert = .close
            }
            else {
                dismiss()
            }
        }
        .disabled(showTitleView)
        Button("Tag", systemImage: "tag") {
            showSelectTagView = true
        }
        .disabled(showTitleView || viewModel.tags.isEmpty)
    }

    /// ツールバーの右側のアイテムを定義するビュー。
    ///
    /// タイトルが空でない場合はリネームのボタンを表示し、常に保存のボタンを表示する。保存のボタンは変更がある場合のみ有効になる。
    @ViewBuilder
    private var toolbarItemTopBarTrailing: some View {
        Button("Rename", systemImage: "rectangle.and.pencil.and.ellipsis") {
            showTitleView = true
            DispatchQueue.main.async {
                inputViewFocus = true
            }
        }
        .disabled(showTitleView)
        .keyboardShortcut("t", modifiers: [.command])
        Button("Save", systemImage: "checkmark.circle.fill") {
            if let memo {
                let oldTitle = memo.title
                let oldContent = memo.content
                let oldTags = memo.tags

                do {
                    try viewModel.update(memo, title: title, content: content, tags: tags)
                    toastMessage = "Successfully saved!"
                }
                catch {
                    self.error = error
                    currentAlert = .error

                    memo.title = oldTitle
                    memo.content = oldContent
                    memo.tags = oldTags
                    print("Failed to update memo: \(error)")
                }
            }
            else {
                let memo = Memo(title: title, content: content, tags: tags)

                do {
                    try viewModel.add(memo)
                    self.memo = memo
                    toastMessage = "Successfully saved!"
                }
                catch {
                    self.error = error
                    currentAlert = .error
                    print("Failed to add memo: \(error)")
                }
            }
        }
        .disabled(!memoUpdated || showTitleView)
        .keyboardShortcut("s", modifiers: [.command])
    }

    /// メモが更新されたかどうかを判定するプロパティ。
    ///
    /// 既存のメモがある場合はタイトルまたは内容が変更されたかどうかを確認し、既存のメモがない場合はタイトルまたは内容が空でないかどうかを確認する。
    private var memoUpdated: Bool {
        if let memo {
            memo.title != title || memo.content != content || memo.tags.sortedByOrder != tags.sortedByOrder
        }
        else {
            !title.isEmpty || !content.isEmpty || !tags.isEmpty
        }
    }
}

#Preview {
    NavigationStack {
        let memo = Memo(title: "Sample Title", content: "Sample Content", createdAt: Date(), updatedAt: Date(), order: .zero)
        EditMemoView(memo: memo)
    }
}
