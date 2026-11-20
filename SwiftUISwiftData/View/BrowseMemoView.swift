//
//  BrowseMemoView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/05/23.
//

import SwiftUI

/// メモの内容を表示するビュー。
struct BrowseMemoView: View {
    @State
    private var viewModel: BrowseMemoViewModel
    @State
    private var tagListViewHeight: CGFloat = .zero
    @State
    private var path = NavigationPath()

    /// メモと Repository からビューを生成する。
    ///
    /// Repository を省略した場合は通常の UserDefaults を使用する。
    init(
        memo: Memo,
        userDefaultsRepository: UserDefaultsRepository = UserDefaultsRepository()
    ) {
        self.init(
            viewModel: BrowseMemoViewModel(
                memo: memo,
                userDefaultsRepository: userDefaultsRepository
            )
        )
    }

    /// 外部で生成した ViewModel を使用する。
    init(viewModel: BrowseMemoViewModel) {
        _viewModel = State(initialValue: viewModel)
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
    let memo = Memo(
        title: "Sample Title",
        content: "Sample Content",
        createdAt: Date(),
        updatedAt: Date(),
        order: .zero
    )

    BrowseMemoView(
        viewModel: BrowseMemoViewModel(
            memo: memo,
            userDefaultsRepository: UserDefaultsRepository()
        )
    )
}
