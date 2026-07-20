//
//  TagInactiveRow.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import SwiftUI

struct TagInactiveRow: View {
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
                    titleLineSpacing: titleLineSpacing,
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 16.5)
                .padding(.horizontal)
                TagColorView(
                    colorString: tag.color,
                    showColorString: true
                )
                .padding(.trailing)
            }
            if showInfo {
                InfoText.dateView(for: tag)
                    .padding(.bottom)
                    .padding(.horizontal)
            }
        }
    }
}

#Preview("white_showColorString_true") {
    TagInactiveRow(
        tag: Tag(title: "Sample Title", color: "#FFFFFF", createdAt: Date(), updatedAt: Date()),
        titleLineLimit: 1,
        titleFontSize: 16.0,
        titleLineSpacing: 0.0,
        showInfo: true,
    )
}

#Preview("white_showColorString_false") {
    TagInactiveRow(
        tag: Tag(title: "Sample Title", color: "#FFFFFF", createdAt: Date(), updatedAt: Date()),
        titleLineLimit: 1,
        titleFontSize: 16.0,
        titleLineSpacing: 0.0,
        showInfo: false,
    )
}

#Preview("black_showColorString_true") {
    TagInactiveRow(
        tag: Tag(title: "Sample Title", color: "#000000", createdAt: Date(), updatedAt: Date()),
        titleLineLimit: 1,
        titleFontSize: 16.0,
        titleLineSpacing: 0.0,
        showInfo: true,
    )
}

#Preview("black_showColorString_false") {
    TagInactiveRow(
        tag: Tag(title: "Sample Title", color: "#000000", createdAt: Date(), updatedAt: Date()),
        titleLineLimit: 1,
        titleFontSize: 16.0,
        titleLineSpacing: 0.0,
        showInfo: false,
    )
}
