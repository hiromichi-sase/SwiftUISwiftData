//
//  MemoInactiveRow.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/23.
//

import SwiftUI

struct MemoInactiveRow: View {
    let memo: Memo
    let titleLineLimit: Int
    let titleFontSize: Float
    let titleLineSpacing: Float
    let showInfo: Bool
    let searchWords: [String]
    let tagsForFiltering: [Tag]
    @State
    private var tagListViewHeight: CGFloat = .zero

    var body: some View {
        HStack(spacing: 8.0) {
            VStack(spacing: 8.0) {
                HStack {
                    MemoRowText(
                        memo: memo,
                        titleLineLimit: titleLineLimit,
                        titleFontSize: titleFontSize,
                        titleLineSpacing: titleLineSpacing,
                        searchWords: searchWords
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                if !memo.tags.isEmpty {
                    TagListView(
                        items: memo.tags.sortedByOrder,
                        content: { tag in
                            TagView(
                                tag: tag,
                                tagForFiltering: tagsForFiltering.contains(tag),
                            )
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
            if memo.protected {
                Image(systemName: "lock.fill")
            }
        }
        .padding()
    }
}
