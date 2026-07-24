//
//  TagView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import SwiftUI

struct TagView: View {
    @Environment(\.colorScheme)
    private var colorScheme
    var tag: Tag
    var tagForFiltering: Bool

    init(
        tag: Tag,
        tagForFiltering: Bool = false,
    ) {
        self.tag = tag
        self.tagForFiltering = tagForFiltering
    }

    var body: some View {
        Text(tag.title)
            .fontWeight(tagForFiltering ? .bold : .regular)
            .foregroundColor(tag.color.color().appropriateTextColor)
            .padding(8)
            .lineLimit(1)
            .truncationMode(.tail)
            .background(tag.color.color())
            .frame(height: 32)
            .cornerRadius(16)
            .overlay(
                Capsule()
                    .stroke(
                        borderColor,
                        lineWidth: 1,
                    )
            )
    }

    private var borderColor: Color {
        if tag.color.color().needsBorder(colorScheme: colorScheme) {
            tag.color.color().appropriateTextColor
        }
        else {
            tag.color.color()
        }
    }
}

#Preview("white_tagForFiltering_false") {
    TagView(tag: Tag(title: "Sample Title", color: "#FFFFFF"), tagForFiltering: false)
}

#Preview("white_tagForFiltering_true") {
    TagView(tag: Tag(title: "Sample Title", color: "#FFFFFF"), tagForFiltering: true)
}

#Preview("black_tagForFiltering_false") {
    TagView(tag: Tag(title: "Sample Title", color: "#000000"), tagForFiltering: false)
}

#Preview("black_tagForFiltering_true") {
    TagView(tag: Tag(title: "Sample Title", color: "#000000"), tagForFiltering: true)
}
