//
//  MemoRow.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/23.
//

import SwiftUI

struct MemoRow: View {
    let memo: Memo
    let titleLineLimit: Int
    let titleFontSize: Float
    let titleLineSpacing: Float
    let showInfo: Bool
    let keywordsForFiltering: [String]
    let tagsForFiltering: [Tag]
    @State
    private var tagListViewHeight: CGFloat = .zero

    init(
        memo: Memo,
        titleLineLimit: Int,
        titleFontSize: Float,
        titleLineSpacing: Float,
        showInfo: Bool,
        keywordsForFiltering: [String] = [],
        tagsForFiltering: [Tag] = [],
    ) {
        self.memo = memo
        self.titleLineLimit = titleLineLimit
        self.titleFontSize = titleFontSize
        self.titleLineSpacing = titleLineSpacing
        self.showInfo = showInfo
        self.keywordsForFiltering = keywordsForFiltering
        self.tagsForFiltering = tagsForFiltering
    }

    var body: some View {
        HStack(spacing: 8.0) {
            VStack(spacing: 8.0) {
                HStack {
                    MemoRowText(
                        memo: memo,
                        titleLineLimit: titleLineLimit,
                        titleFontSize: titleFontSize,
                        titleLineSpacing: titleLineSpacing,
                        keywordsForFiltering: keywordsForFiltering
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

#Preview("active") {
    MemoRow(
        memo: Memo(
            title: "Sample Title",
            content: "Sample Content",
            createdAt: Date(),
            updatedAt: Date(),
            order: .zero,
            protected: false,
            tags: [
                Tag(
                    title: "Sample Tag 1",
                    color: "#000000"
                )
            ]
        ),
        titleLineLimit: 0,
        titleFontSize: 16.0,
        titleLineSpacing: 0.0,
        showInfo: false,
    )
}

#Preview("inactive") {
    MemoRow(
        memo: Memo(
            title: "Sample Title",
            content: "Sample Content",
            createdAt: Date(),
            updatedAt: Date(),
            order: .zero,
            protected: false,
            tags: [
                Tag(
                    title: "Sample Tag 1",
                    color: "#FFFFFF"
                )
            ]
        ),
        titleLineLimit: 0,
        titleFontSize: 16.0,
        titleLineSpacing: 0.0,
        showInfo: false,
        keywordsForFiltering: ["Sample"],
        tagsForFiltering: [
            Tag(
                title: "Sample Tag 1",
                color: "#FFFFFF"
            )
        ],
    )
}
