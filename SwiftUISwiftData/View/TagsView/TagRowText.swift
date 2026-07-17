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

    var body: some View {
        Text(tag.title.isEmpty ? CommonString.noTitle : tag.title)
            .foregroundStyle(tag.title.isEmpty ? .secondary : .primary)
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
