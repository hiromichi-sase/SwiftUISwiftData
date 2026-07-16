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
            TagRowText(
                tag: tag,
                titleLineLimit: titleLineLimit,
                titleFontSize: titleFontSize,
                titleLineSpacing: titleLineSpacing,
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            if showInfo {
                InfoText.dateView(for: tag)
            }
        }
    }
}
