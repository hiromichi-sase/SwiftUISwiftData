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
    @ObservedObject var viewModel = BrowseMemoViewModel(repository: MemoRepository(modelContainer: ModelContainerManager.shared.modelContainer))

    /// 表示するメモ
    private var memo: Memo
    /// 編集画面を開くかどうかのフラグ
    @State private var openEditMemoView = false

    /// タイトルと内容の状態変数
    @State private var title: String
    /// 内容の状態変数
    @State private var content: String
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
        self._title = State(initialValue: memo.title)
        self._content = State(initialValue: memo.content)
        self._openEditMemoView = State(initialValue: openEditMemoView)
        self._toastMessage = State(initialValue: "")
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                TextView(text: $content, isEditable: false, defaultText: CommonString.emptyContent.rawValue)
                    .border(.clear)
            }
            .padding(.top, 0)
            .padding([.horizontal, .bottom], 16)
            .onAppear {
                if openEditMemoView {
                    showingEditMemo = true
                    openEditMemoView = false
                }
            }
            .onReceive(willSavePublisher) { _ in
                title = memo.title
                content = memo.content
            }
            .fullScreenCover(isPresented: $showingEditMemo) {
                EditMemoView(memo: memo)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    toolbarItemTopBarTrailing
                }
            }
            .toast(message: $toastMessage)
        }
    }

    /// メモが更新されたかどうかを判定するプロパティ
    private var memoUpdated: Bool {
        memo.title != title || memo.content != content
    }

    /// モデルコンテキストの保存前に通知を受け取るためのパブリッシャー
    private var willSavePublisher: NotificationCenter.Publisher {
        NotificationCenter.default
            .publisher(for: ModelContext.willSave, object: viewModel.modelContext)
    }

    /// ツールバーの右側のアイテムを定義するビュー。タイトルが空でない場合はコピーのボタンを表示し、常に編集のボタンを表示する。
    @ViewBuilder
    private var toolbarItemTopBarTrailing: some View {
        if !title.isEmpty {
            Button("Copy", systemImage: "doc.on.doc") {
                UIPasteboard.general.string = $title.wrappedValue
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
