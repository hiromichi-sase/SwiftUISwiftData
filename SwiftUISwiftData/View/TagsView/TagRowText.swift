//
//  TagRowText.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import SwiftUI

struct TagRowText: View {
    let tag: Tag
    let titleLineLimit: Int
    let titleFontSize: Float
    let titleLineSpacing: Float

    private var isTitleEmpty: Bool {
        tag.title.isEmpty
    }

    private var displayTitle: String {
        isTitleEmpty ? CommonString.noTitle : tag.title
    }

    var body: some View {
        Text(displayTitle)
            .foregroundStyle(isTitleEmpty ? .secondary : .primary)
            .lineLimit(titleLineLimit)
            .font(.system(size: CGFloat(titleFontSize)))
            .lineSpacing(CGFloat(titleLineSpacing))
    }
}

#Preview {
    TagRowText(
        tag: Tag(title: "Sample Title", color: "#000000"),
        titleLineLimit: 1,
        titleFontSize: 16.0,
        titleLineSpacing: 0.0
    )
}
