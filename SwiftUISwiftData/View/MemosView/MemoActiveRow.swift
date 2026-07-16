//
//  MemoActiveRow.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/23.
//

import SwiftUI

struct MemoActiveRow: View {
    let memo: Memo
    let titleLineLimit: Int
    let titleFontSize: Float
    let titleLineSpacing: Float
    let showInfo: Bool
    @State
    private var tagListViewHeight: CGFloat = .zero

    var body: some View {
        VStack(spacing: .zero) {
            HStack {
                MemoRowText(
                    memo: memo,
                    titleLineLimit: titleLineLimit,
                    titleFontSize: titleFontSize,
                    titleLineSpacing: titleLineSpacing
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                if memo.protected {
                    Image(systemName: "lock.fill")
                }
            }
            .padding(.bottom)
            TagListView(
                items: memo.tags.sorted { $0.order < $1.order },
                content: { tag in
                    TagView(tag: tag)
                },
                viewHeight: { height in
                    tagListViewHeight = height
                }
            )
            .frame(height: tagListViewHeight)
            if showInfo {
                VStack(alignment: .leading, spacing: .zero) {
                    InfoText.countView(content: memo.content)
                    InfoText.dateView(for: memo)
                }
                .padding(.top)
            }
        }
    }
}
