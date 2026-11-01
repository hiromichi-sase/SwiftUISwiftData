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
    @State
    private var viewModel: BrowseMemoViewModel
    /// タグ一覧の高さ。
    @State
    private var tagListViewHeight: CGFloat = .zero
    /// ナビゲーションパスの状態変数。
    @State
    private var path = NavigationPath()

    /// イニシャライザ。
    /// - Parameter memo: 表示するメモ
    init(memo: Memo) {
        _viewModel = State(
            wrappedValue: BrowseMemoViewModel(
                memo: memo,
                userDefaultsRepository: UserDefaultsRepository()
            )
        )
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 4) {
                TextView(
                    text: Binding(
                        get: { viewModel.memo.content },
                        set: { _ in }
                    ),
                    isEditable: false,
                    defaultText: CommonString.noContent,
                    hasLink: viewModel.hasLink,
                    contentFontSize: viewModel.contentFontSize,
                    contentLineSpacing: viewModel.contentLineSpacing
                )
                .disabled(viewModel.isContentEmpty)
                tagListView
                if viewModel.showInfo {
                    VStack(alignment: .leading, spacing: .zero) {
                        InfoText.countView(content: viewModel.displayContent)
                        InfoText.dateView(for: viewModel.memo)
                    }
                }
            }
            .padding(.top, .zero)
            .padding([.horizontal, .bottom], 16)
            .fullScreenCover(
                isPresented: $viewModel.showingEditMemo,
                onDismiss: { viewModel.dismissEdit() }
            ) {
                EditMemoView(memo: viewModel.memo)
            }
            .navigationTitle(viewModel.title)
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
        if !viewModel.tagsSortedByOrder.isEmpty {
            TagListView(
                items: viewModel.tagsSortedByOrder,
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
    @ViewBuilder
    private var toolbarItemTopBarTrailing: some View {
        if !viewModel.isProtected {
            Button("Edit", systemImage: "pencil") {
                viewModel.editButtonTapped()
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
