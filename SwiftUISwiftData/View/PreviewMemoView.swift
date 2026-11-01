//
//  PreviewMemoView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/05/04.
//

import SwiftData
import SwiftUI

/// メモの内容をプレビュー表示するビュー。
struct PreviewMemoView: View {
    /// ビューモデルの状態変数。
    @State
    private var viewModel: PreviewMemoViewModel

    init(memo: Memo) {
        _viewModel = State(
            wrappedValue: PreviewMemoViewModel(
                memo: memo,
                userDefaultsRepository: UserDefaultsRepository()
            )
        )
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text(viewModel.displayContent)
                    .font(.system(size: CGFloat(viewModel.contentFontSize)))
                    .lineSpacing(CGFloat(viewModel.contentLineSpacing))
                    .foregroundStyle(viewModel.isContentEmpty ? .secondary : .primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()
            .background(Color(uiColor: .systemGray5))
        }
    }
}

#Preview {
    NavigationStack {
        let memo = Memo(title: "Sample Title", content: "Sample Content", createdAt: Date(), updatedAt: Date(), order: .zero)
        PreviewMemoView(memo: memo)
    }
}
