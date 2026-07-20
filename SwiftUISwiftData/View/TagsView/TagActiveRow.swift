//
//  TagActiveRow.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import SwiftUI

struct TagActiveRow: View {
    let tag: Tag
    let titleLineLimit: Int
    let titleFontSize: Float
    let titleLineSpacing: Float
    let showInfo: Bool

    var body: some View {
        VStack(spacing: .zero) {
            HStack {
                TagRowText(
                    tag: tag,
                    titleLineLimit: titleLineLimit,
                    titleFontSize: titleFontSize,
                    titleLineSpacing: titleLineSpacing
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                Text(tag.color)
                    .frame(width: 90)
                    .foregroundStyle(tag.color.color().appropriateTextColor)
                    .background(tag.color.color())
                    .border(tag.color.color().appropriateTextColor)
            }
            if showInfo {
                VStack(alignment: .leading, spacing: .zero) {
                    InfoText.dateView(for: tag)
                }
                .padding(.top)
            }
        }
    }
}

#Preview("white_showColorString_true") {
    TagActiveRow(
        tag: Tag(title: "Sample Title", color: "#FFFFFF", createdAt: Date(), updatedAt: Date()),
        titleLineLimit: 1,
        titleFontSize: 16.0,
        titleLineSpacing: 0.0,
        showInfo: true,
    )
}

#Preview("white_showColorString_false") {
    TagActiveRow(
        tag: Tag(title: "Sample Title", color: "#FFFFFF", createdAt: Date(), updatedAt: Date()),
        titleLineLimit: 1,
        titleFontSize: 16.0,
        titleLineSpacing: 0.0,
        showInfo: false,
    )
}

#Preview("black_showColorString_true") {
    TagActiveRow(
        tag: Tag(title: "Sample Title", color: "#000000", createdAt: Date(), updatedAt: Date()),
        titleLineLimit: 1,
        titleFontSize: 16.0,
        titleLineSpacing: 0.0,
        showInfo: true,
    )
}

#Preview("black_showColorString_false") {
    TagActiveRow(
        tag: Tag(title: "Sample Title", color: "#000000", createdAt: Date(), updatedAt: Date()),
        titleLineLimit: 1,
        titleFontSize: 16.0,
        titleLineSpacing: 0.0,
        showInfo: false,
    )
}
