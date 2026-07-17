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
        VStack(spacing: 8.0) {
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
            if !memo.tags.isEmpty {
                TagListView(
                    items: memo.tags.sortedByOrder,
                    content: { tag in
                        TagView(tag: tag)
                    },
                    viewHeight: { height in
                        tagListViewHeight = height
                    }
                )
                .frame(height: tagListViewHeight)
            }
            if showInfo {
                VStack(alignment: .leading, spacing: .zero) {
                    InfoText.countView(content: memo.content)
                    InfoText.dateView(for: memo)
                }
            }
        }
    }
}
