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
    @State
    private var tagListViewHeight: CGFloat = .zero

    var body: some View {
        VStack(spacing: .zero) {
            HStack {
                MemoRowText(
                    memo: memo,
                    titleLineLimit: titleLineLimit,
                    titleFontSize: titleFontSize,
                    titleLineSpacing: titleLineSpacing,
                    searchWords: searchWords
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                if memo.protected {
                    Image(systemName: "lock.fill")
                        .padding(.trailing)
                }
            }
            HStack {
                Spacer()
                    .frame(width: 16)
                TagListView(
                    items: memo.tags,
                    content: { tag in
                        TagView(tag: tag)
                    },
                    viewHeight: { height in
                        tagListViewHeight = height
                    }
                )
                .frame(height: tagListViewHeight)
                Spacer()
                    .frame(width: 16)
            }
            .padding(.bottom)
            if showInfo {
                VStack(alignment: .leading, spacing: .zero) {
                    InfoText.countView(content: memo.content)
                    InfoText.dateView(for: memo)
                }
                .padding(.bottom)
                .padding(.horizontal)
            }
        }
    }
}
