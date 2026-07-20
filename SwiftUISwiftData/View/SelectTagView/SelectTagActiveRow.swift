//
//  SelectSelectTagActiveRow.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/20.
//

import SwiftUI

struct SelectTagActiveRow: View {
    let tag: Tag
    let titleLineLimit: Int
    let titleFontSize: Float
    let titleLineSpacing: Float

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
                TagColorView(
                    colorString: tag.color,
                    showColorString: false
                )
            }
        }
    }
}

#Preview("white") {
    SelectTagActiveRow(
        tag: Tag(title: "Sample Title", color: "#FFFFFF"),
        titleLineLimit: 1,
        titleFontSize: 16.0,
        titleLineSpacing: 0.0,
    )
}

#Preview("black") {
    SelectTagActiveRow(
        tag: Tag(title: "Sample Title", color: "#000000"),
        titleLineLimit: 1,
        titleFontSize: 16.0,
        titleLineSpacing: 0.0,
    )
}
