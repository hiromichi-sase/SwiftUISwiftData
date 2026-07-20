//
//  TagView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import SwiftUI

struct TagView: View {
    var tag: Tag

    var body: some View {
        Text(tag.title)
            .foregroundColor(tag.color.color().appropriateTextColor)
            .padding(8)
            .lineLimit(1)
            .truncationMode(.tail)
            .background(tag.color.color())
            .frame(height: 32)
            .cornerRadius(16)
            .overlay(
                Capsule()
                    .stroke(tag.color.color().appropriateTextColor, lineWidth: 1)
            )
    }
}

#Preview("white") {
    TagView(tag: Tag(title: "Sample Title", color: "#FFFFFF"))
}

#Preview("black") {
    TagView(tag: Tag(title: "Sample Title", color: "#000000"))
}
