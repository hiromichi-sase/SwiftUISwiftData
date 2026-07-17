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
    let showColorString: Bool

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
                Text(showColorString ? tag.color : "")
                    .frame(width: showColorString ? 90 : 30)
                    .foregroundStyle(tag.color.color().appropriateTextColor)
                    .background(tag.color.color())
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

#Preview("showColorString_true") {
    TagActiveRow(
        tag: Tag(title: "Sample Title", color: "#000000"),
        titleLineLimit: 1,
        titleFontSize: 16.0,
        titleLineSpacing: 0.0,
        showInfo: false,
        showColorString: true
    )
}

#Preview("showColorString_false") {
    TagActiveRow(
        tag: Tag(title: "Sample Title", color: "#000000"),
        titleLineLimit: 1,
        titleFontSize: 16.0,
        titleLineSpacing: 0.0,
        showInfo: false,
        showColorString: false
    )
}
