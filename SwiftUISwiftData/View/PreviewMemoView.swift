//
//  PreviewMemoView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/05/04.
//

import SwiftUI

/// メモの内容をプレビュー表示するビュー。
struct PreviewMemoView: View {
    @State
    private var viewModel: PreviewMemoViewModel

    /// メモと Repository からビューを生成する。
    ///
    /// Repository を省略した場合は通常の UserDefaults を使用する。
    init(
        memo: Memo,
        userDefaultsRepository: UserDefaultsRepository = UserDefaultsRepository()
    ) {
        self.init(
            viewModel: PreviewMemoViewModel(
                memo: memo,
                userDefaultsRepository: userDefaultsRepository
            )
        )
    }

    /// 外部で生成した ViewModel を使用する。
    init(viewModel: PreviewMemoViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text(viewModel.displayContent)
                    .font(.system(size: CGFloat(viewModel.contentFontSize)))
                    .lineSpacing(CGFloat(viewModel.contentLineSpacing))
                    .foregroundStyle(
                        viewModel.isContentEmpty ? .secondary : .primary
                    )
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
            .padding()
            .background(Color(uiColor: .systemGray5))
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
    PreviewMemoView(memo: memo)
}
