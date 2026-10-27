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
    @ObservedObject
    var viewModel = PreviewMemoViewModel(
        userDefaultsRepository: UserDefaultsRepository()
    )
    /// 表示するメモのデータ。
    var memo: Memo

    private var isContentEmpty: Bool {
        memo.content.isEmpty
    }

    private var displayContent: String {
        isContentEmpty ? CommonString.noContent : memo.content
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text(displayContent)
                    .font(.system(size: CGFloat(viewModel.getContentFontSize())))
                    .lineSpacing(CGFloat(viewModel.getContentLineSpacing()))
                    .foregroundStyle(isContentEmpty ? .secondary : .primary)
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
