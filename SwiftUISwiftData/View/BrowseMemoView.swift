//
//  BrowseMemoView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/05/23.
//

import SwiftData
import SwiftUI

/// メモの内容を表示するビュー。
struct BrowseMemoView: View {
    /// ビューの状態を管理するViewModel。
    @ObservedObject
    var viewModel = BrowseMemoViewModel(
        userDefaultsRepository: UserDefaultsRepository()
    )
    /// 表示するメモ。
    @State
    private var memo: Memo
    /// 編集画面を表示するかどうかのフラグ。
    @State
    private var showingEditMemo = false
    @State
    private var tagListViewHeight: CGFloat = .zero
    /// ナビゲーションパスの状態変数。
    @State
    var path = NavigationPath()

    /// イニシャライザ。
    /// - Parameter memo: 表示するメモ
    init(memo: Memo) {
        self.memo = memo
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 4) {
                TextView(
                    text: $memo.content,
                    isEditable: false,
                    defaultText: CommonString.noContent,
                    hasLink: viewModel.getHasLink(),
                    contentFontSize: viewModel.getContentFontSize(),
                    contentLineSpacing: viewModel.getContentLineSpacing()
                )
                .disabled(memo.content.isEmpty)
                tagListView
                if viewModel.getShowInfo() {
                    VStack(alignment: .leading, spacing: .zero) {
                        InfoText.countView(content: memo.content)
                        InfoText.dateView(for: memo)
                    }
                }
            }
            .padding(.top, .zero)
            .padding([.horizontal, .bottom], 16)
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
        }
    }

    @ViewBuilder
    private var tagListView: some View {
        if !memo.tags.isEmpty {
            TagListView(
                items: memo.tags.sortedByOrder,
                content: { tag in
                    TagView(tag: tag)
                },
                viewHeight: updateTagListViewHeight
            )
            .frame(height: tagListViewHeight)
        }
    }

    private func updateTagListViewHeight(_ height: CGFloat) {
        tagListViewHeight = height
    }

    /// ツールバーの右側のアイテムを定義するビュー。
    ///
    /// タイトルが空でない場合はコピーのボタンを表示し、常に編集のボタンを表示する。
    @ViewBuilder
    private var toolbarItemTopBarTrailing: some View {
        if !memo.protected {
            Button("Edit", systemImage: "pencil") {
                showingEditMemo = true
            }
            .keyboardShortcut("e", modifiers: [.command, .shift])
        }
    }
}

#Preview {
    NavigationStack {
        let memo = Memo(title: "Sample Title", content: "Sample Content", createdAt: Date(), updatedAt: Date(), order: .zero)
        BrowseMemoView(memo: memo)
    }
}
