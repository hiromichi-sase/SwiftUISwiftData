//
//  TagRow.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import SwiftUI

struct TagRow: View {
    let tag: Tag
    let titleLineLimit: Int
    let titleFontSize: Float
    let titleLineSpacing: Float
    let showColorString: Bool
    let showInfo: Bool
    let showTagCount: Bool

    init(
        tag: Tag,
        titleLineLimit: Int,
        titleFontSize: Float,
        titleLineSpacing: Float,
        showColorString: Bool,
        showInfo: Bool = false,
        showTagCount: Bool = false,
    ) {
        self.tag = tag
        self.titleLineLimit = titleLineLimit
        self.titleFontSize = titleFontSize
        self.titleLineSpacing = titleLineSpacing
        self.showColorString = showColorString
        self.showInfo = showInfo
        self.showTagCount = showTagCount
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            HStack {
                TagRowText(
                    tag: tag,
                    titleLineLimit: titleLineLimit,
                    titleFontSize: titleFontSize,
                    titleLineSpacing: titleLineSpacing,
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                TagColorView(
                    colorString: tag.color,
                    showColorString: showColorString
                )
            }
            if showTagCount, tag.memos.count > .zero {
                Text("\(tag.memos.count) Memo\(tag.memos.count == 1 ? "" : "s")")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 12.0))
            }
            if showInfo {
                InfoText.dateView(for: tag)
            }
        }
        .padding()
    }
}

#Preview("white_showColorString_true") {
    TagRow(
        tag: Tag(title: "Sample Title", color: "#FFFFFF", createdAt: Date(), updatedAt: Date()),
        titleLineLimit: 1,
        titleFontSize: 16.0,
        titleLineSpacing: 0.0,
        showColorString: true,
        showInfo: true,
    )
}

#Preview("white_showColorString_false") {
    TagRow(
        tag: Tag(title: "Sample Title", color: "#FFFFFF", createdAt: Date(), updatedAt: Date()),
        titleLineLimit: 1,
        titleFontSize: 16.0,
        titleLineSpacing: 0.0,
        showColorString: true,
        showInfo: false,
    )
}

#Preview("white_showColorString_showTagCount") {
    TagRow(
        tag: Tag(
            title: "Sample Title",
            color: "#FFFFFF",
            createdAt: Date(),
            updatedAt: Date(),
            memos: [
                Memo(title: "Sample Memo", content: "Sample Content", createdAt: Date(), updatedAt: Date(), order: .zero)
            ]
        ),
        titleLineLimit: 1,
        titleFontSize: 16.0,
        titleLineSpacing: 0.0,
        showColorString: true,
        showInfo: false,
        showTagCount: true,
    )
}

#Preview("black_showColorString_true") {
    TagRow(
        tag: Tag(title: "Sample Title", color: "#000000", createdAt: Date(), updatedAt: Date()),
        titleLineLimit: 1,
        titleFontSize: 16.0,
        titleLineSpacing: 0.0,
        showColorString: true,
        showInfo: true,
    )
}

#Preview("black_showColorString_false") {
    TagRow(
        tag: Tag(title: "Sample Title", color: "#000000", createdAt: Date(), updatedAt: Date()),
        titleLineLimit: 1,
        titleFontSize: 16.0,
        titleLineSpacing: 0.0,
        showColorString: true,
        showInfo: false,
    )
}

#Preview("black_showColorString_showTagCount") {
    TagRow(
        tag: Tag(
            title: "Sample Title",
            color: "#000000",
            createdAt: Date(),
            updatedAt: Date(),
            memos: [
                Memo(title: "Sample Memo", content: "Sample Content", createdAt: Date(), updatedAt: Date(), order: .zero)
            ]
        ),
        titleLineLimit: 1,
        titleFontSize: 16.0,
        titleLineSpacing: 0.0,
        showColorString: true,
        showInfo: false,
        showTagCount: true,
    )
}
