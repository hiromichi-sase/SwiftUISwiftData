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
    let tag: Tag
    let tagForFiltering: Bool

    init(
        tag: Tag,
        tagForFiltering: Bool = false,
    ) {
        self.tag = tag
        self.tagForFiltering = tagForFiltering
    }

    private var tagColor: Color {
        tag.color.color()
    }

    private var textColor: Color {
        tagColor.appropriateTextColor
    }

    var body: some View {
        Text(tag.title)
            .fontWeight(tagForFiltering ? .bold : .regular)
            .foregroundColor(textColor)
            .lineLimit(1)
            .truncationMode(.tail)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(height: 32)
            .background(tagColor)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(
                        borderColor,
                        lineWidth: tagForFiltering ? 2 : 1,
                    )
            )
    }

    private var borderColor: Color {
        if tagColor.needsBorder(colorScheme: colorScheme) {
            textColor
        }
        else {
            tagColor
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
