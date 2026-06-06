//
//  EditMemoView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/05/04.
//

import SwiftData
import SwiftUI

/// メモの内容を編集するビュー
struct EditMemoView: View {
    /// ビューモデルの状態変数
    @ObservedObject var viewModel = EditMemoViewModel(repository: MemoRepository(modelContainer: ModelContainerManager.shared.modelContainer))

    /// ビューを閉じるための環境変数
    @Environment(\.dismiss) private var dismiss

    /// 編集中のメモ
    @State private var memo: Memo?

    /// タイトルと内容の状態変数
    @State private var title: String
    /// 保存前のタイトルを保持する状態変数
    @State private var titleToStore: String = ""
    /// 内容の状態変数
    @State private var content: String
    /// 変更を破棄するかどうかの確認アラートを表示するフラグ
    @State private var showConfirmationAlert = false
    /// タイトル編集ビューを表示するフラグ
    @State private var showTitleView = false
    /// トーストメッセージの状態変数
    @State private var toastMessage = ""

    /// テキストフィールドとテキストビューのフォーカス状態
    @FocusState private var textViewFocus: Bool
    /// テキストフィールドのフォーカス状態
    @FocusState private var textFieldFocus: Bool

    /// ナビゲーションパスの状態変数
    @State var path = NavigationPath()

    /// イニシャライザ
    /// - Parameter memo: 編集するメモ（デフォルトはnilで新規作成）
    init(memo: Memo? = nil) {
        self.memo = memo
        self._title = State(initialValue: memo?.title ?? "")
        self._content = State(initialValue: memo?.content ?? "")
        self._titleToStore = State(initialValue: memo?.title ?? "")
        self._toastMessage = State(initialValue: "")
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 8) {
                if showTitleView {
                    titleView
                }
                contentView
            }
            .padding(.top, 0)
            .padding([.horizontal, .bottom], 16)
            .onAppear {
                textViewFocus = true
            }
            .alert(isPresented: $showConfirmationAlert) {
                Alert(
                    title: Text("Discard changes?"),
                    primaryButton: .destructive(Text("Discard")) {
                        dismiss()
                    },
                    secondaryButton: .cancel()
                )
            }
            .navigationTitle(titleToStore)
            .navigationBarTitleDisplayMode(.inline)
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

    /// タイトル編集ビュー
    private var titleView: some View {
        HStack(spacing: 8) {
            Button("", systemImage: "xmark") {
                title = titleToStore
                showTitleView = false
            }
            .imageScale(.large)
            TextField("Title", text: $title)
                .padding(6)
                .border(.primary)
                .focused($textFieldFocus)
                .submitLabel(.done)
                .onSubmit {
                    titleToStore = title
                    showTitleView = false
                }
            Button("", systemImage: "eraser") {
                title = ""
            }
            .imageScale(.large)
        }
    }

    /// 内容編集ビュー
    private var contentView: some View {
        TextView(text: $content, isEditable: !showTitleView)
            .border(showTitleView ? .secondary : .primary)
            .focused($textViewFocus)
            .disabled(showTitleView)
            .overlay(alignment: .topLeading) {
                if content.isEmpty {
                    Text("Input Content")
                        .allowsHitTesting(false)
                        .foregroundColor(Color(uiColor: .placeholderText))
                        .padding(6)
                }
            }
    }

    /// ツールバーの左側のアイテムを定義するビュー。変更がある場合は確認アラートを表示し、変更がない場合はビューを閉じる。
    @ViewBuilder
    private var toolbarItemTopBarLeading: some View {
        Button("Cancel", systemImage: "xmark") {
            if memoUpdated {
                showConfirmationAlert = true
            } else {
                dismiss()
            }
        }
        .disabled(showTitleView)
    }

    /// ツールバーの右側のアイテムを定義するビュー。タイトルが空でない場合はリネームのボタンを表示し、常に保存のボタンを表示する。保存のボタンは変更がある場合のみ有効になる。
    @ViewBuilder
    private var toolbarItemTopBarTrailing: some View {
        Button("Rename", systemImage: "rectangle.and.pencil.and.ellipsis") {
            showTitleView = true
            textFieldFocus = true
        }
        .disabled(showTitleView)
        Button("Save", systemImage: "square.and.pencil") {
            if let memo {
                memo.title = title
                memo.content = content

                do {
                    try viewModel.update(memo)
                    toastMessage = "Successfully saved!"
                } catch {
                    print("Failed to update memo: \(error)")
                }
            } else {
                let memo = Memo(title: title, content: content)

                do {
                    try viewModel.add(memo)
                    self.memo = memo
                    toastMessage = "Successfully saved!"
                } catch {
                    print("Failed to add memo: \(error)")
                }
            }
        }
        .disabled(!memoUpdated || showTitleView)
    }

    /// メモが更新されたかどうかを判定するプロパティ。既存のメモがある場合はタイトルまたは内容が変更されたかどうかを確認し、既存のメモがない場合はタイトルまたは内容が空でないかどうかを確認する。
    private var memoUpdated: Bool {
        if let memo {
            memo.title != titleToStore || memo.content != content
        } else {
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
