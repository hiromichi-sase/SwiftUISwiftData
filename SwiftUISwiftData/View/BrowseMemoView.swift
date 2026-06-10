//
//  BrowseMemoView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/05/23.
//

import SwiftData
import SwiftUI

/// メモの内容を表示するビュー
struct BrowseMemoView: View {
    /// ビューの状態を管理するViewModel
    @ObservedObject var viewModel = BrowseMemoViewModel(
        memoRepository: MemoRepository(modelContainer: ModelContainerManager.shared.modelContainer),
        userDefaultsRepository: UserDefaultsRepository()
    )

    /// 表示するメモ
    @State private var memo: Memo
    /// 編集画面を開くかどうかのフラグ
    @State private var openEditMemoView = false

    /// 編集画面を表示するかどうかのフラグ
    @State private var showingEditMemo = false
    /// トーストメッセージの状態変数
    @State private var toastMessage = ""

    /// ナビゲーションパスの状態変数
    @State var path = NavigationPath()

    /// イニシャライザ
    /// - Parameters:
    ///   - memo: 表示するメモ
    ///   - openEditMemoView: 編集画面を開くかどうかのフラグ（デフォルトはfalse）
    init(memo: Memo, openEditMemoView: Bool = false) {
        self.memo = memo
        self._openEditMemoView = State(initialValue: openEditMemoView)
        self._toastMessage = State(initialValue: "")
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                TextView(
                    text: $memo.content,
                    isEditable: false,
                    defaultText: CommonString.noContent,
                    hasLink: viewModel.getHasLink(),
                    contentFontSize: viewModel.getContentFontSize(),
                    contentLineSpacing: viewModel.getContentLineSpacing()
                )
                .border(.clear)
                .disabled(memo.content.isEmpty)
            }
            .padding(.top, 0)
            .padding([.horizontal, .bottom], 16)
            .onAppear {
                if openEditMemoView {
                    showingEditMemo = true
                    openEditMemoView = false
                }
            }
            .fullScreenCover(isPresented: $showingEditMemo) {
                EditMemoView(memo: memo)
            }
            .navigationTitle(memo.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    toolbarItemTopBarTrailing
                }
            }
            .toast(message: $toastMessage)
        }
    }

    /// ツールバーの右側のアイテムを定義するビュー。タイトルが空でない場合はコピーのボタンを表示し、常に編集のボタンを表示する。
    @ViewBuilder
    private var toolbarItemTopBarTrailing: some View {
        if !memo.title.isEmpty {
            Button("Copy", systemImage: "doc.on.doc") {
                UIPasteboard.general.string = memo.title
                toastMessage = "Successfully copied!"
            }
        }
        Button("Edit", systemImage: "pencil") {
            showingEditMemo = true
        }
    }
}

#Preview {
    NavigationStack {
        let memo = Memo(title: "Sample Title", content: "Sample Content", createdAt: Date(), updatedAt: Date(), order: 0)
        BrowseMemoView(memo: memo)
    }
}
