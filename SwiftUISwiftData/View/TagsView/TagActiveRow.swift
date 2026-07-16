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
                    .frame(width: 80)
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
