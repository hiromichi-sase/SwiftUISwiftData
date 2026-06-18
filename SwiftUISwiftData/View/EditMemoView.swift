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
    /// ビューモデルの状態変数。
    @ObservedObject
    var viewModel = EditMemoViewModel(
        memoRepository: MemoRepository(modelContainer: ModelContainerManager.shared.modelContainer),
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
    /// 保存前のタイトルを保持する状態変数。
    @State
    private var titleToStore: String = ""
    /// 内容の状態変数。
    @State
    private var content: String
    /// 変更を破棄して閉じるかどうかの確認アラートを表示するフラグ。
    @State
    private var showCloseAlert = false
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
    private var showErrorAlert = false
    /// ナビゲーションパスの状態変数。
    @State
    var path = NavigationPath()

    /// イニシャライザ。
    /// - Parameter memo: 編集するメモ（デフォルトはnilで新規作成）
    init(memo: Memo? = nil) {
        self.memo = memo
        self._title = State(initialValue: memo?.title ?? "")
        self._content = State(initialValue: memo?.content ?? "")
        self._titleToStore = State(initialValue: memo?.title ?? "")
        self._toastMessage = State(initialValue: "")
        self._error = State(initialValue: nil)
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 4) {
                if showTitleView {
                    titleView
                }
                contentView
                if viewModel.getShowDate() {
                    HStack(spacing: 0) {
                        DateText(memo?.createdAt, style: .createdAt)
                        Spacer()
                        DateText(memo?.updatedAt, style: .updatedAt)
                    }
                }
            }
            .padding(.top, 0)
            .padding([.horizontal, .bottom], 16)
            .onAppear {
                textEditorFocus = true
                DispatchQueue.main.async {
                    textSelection = .init(insertionPoint: content.startIndex)
                }
            }
            .alert(isPresented: $showCloseAlert) {
                closeAlert
            }
            .alert("The Error occured.", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(error?.localizedDescription ?? "")
            }
            .navigationTitle(titleToStore)
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
        }
    }

    /// タイトル編集ビュー。
    private var titleView: some View {
        HStack(spacing: 8) {
            TextField("Input Title", text: $title)
                .padding(6)
                .border(.primary)
                .focused($textFieldFocus)
                .submitLabel(.done)
                .onSubmit {
                    titleToStore = title
                    showTitleView = false
                }
        }
        .padding(.bottom, 4)
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

    /// ツールバーの左側のアイテムを定義するビュー。
    ///
    /// 変更がある場合は確認アラートを表示し、変更がない場合はビューを閉じる。
    @ViewBuilder
    private var toolbarItemTopBarLeading: some View {
        Button("Close", systemImage: "xmark") {
            if memoUpdated {
                showCloseAlert = true
            }
            else {
                dismiss()
            }
        }
        .disabled(showTitleView)
    }

    /// ツールバーの右側のアイテムを定義するビュー。
    ///
    /// タイトルが空でない場合はリネームのボタンを表示し、常に保存のボタンを表示する。保存のボタンは変更がある場合のみ有効になる。
    @ViewBuilder
    private var toolbarItemTopBarTrailing: some View {
        Button("Rename", systemImage: "rectangle.and.pencil.and.ellipsis") {
            showTitleView.toggle()
            if showTitleView {
                textFieldFocus = true
            }
            else {
                title = titleToStore
            }
        }
        Button("Save", systemImage: "square.and.pencil") {
            if let memo {
                let oldTitle = memo.title
                let oldContent = memo.content

                do {
                    try viewModel.update(memo, title: title, content: content)
                    toastMessage = "Successfully saved!"
                }
                catch {
                    self.error = error
                    showErrorAlert = true

                    memo.title = oldTitle
                    memo.content = oldContent
                    print("Failed to update memo: \(error)")
                }
            }
            else {
                let memo = Memo(title: title, content: content)

                do {
                    try viewModel.add(memo)
                    self.memo = memo
                    toastMessage = "Successfully saved!"
                }
                catch {
                    self.error = error
                    showErrorAlert = true
                    print("Failed to add memo: \(error)")
                }
            }
        }
        .disabled(!memoUpdated || showTitleView)
    }

    /// メモが更新されたかどうかを判定するプロパティ。
    ///
    /// 既存のメモがある場合はタイトルまたは内容が変更されたかどうかを確認し、既存のメモがない場合はタイトルまたは内容が空でないかどうかを確認する。
    private var memoUpdated: Bool {
        if let memo {
            memo.title != titleToStore || memo.content != content
        }
        else {
            !titleToStore.isEmpty || !content.isEmpty
        }
    }
}

#Preview {
    NavigationStack {
        let memo = Memo(title: "Sample Title", content: "Sample Content", createdAt: Date(), updatedAt: Date(), order: 0)
        EditMemoView(memo: memo)
    }
}
