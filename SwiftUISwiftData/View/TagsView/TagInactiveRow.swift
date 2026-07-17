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
                .padding()
                Text(tag.color)
                    .frame(width: 80)
                    .foregroundStyle(tag.color.color().appropriateTextColor)
                    .background(tag.color.color())
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

#Preview {
    TagInactiveRow(
        tag: Tag(title: "Sample Title", color: "#000000"),
        titleLineLimit: 1,
        titleFontSize: 16.0,
        titleLineSpacing: 0.0,
        showInfo: false
    )
}
