//
//  TagColorView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/20.
//

import SwiftUI

struct TagColorView: View {
    var tag: Tag
    var showColorString: Bool

    var body: some View {
        if showColorString {
            Text(tag.color)
                .frame(width: 90)
                .foregroundStyle(tag.color.color().appropriateTextColor)
                .background(tag.color.color())
                .border(tag.color.color().appropriateTextColor)
        }
        else {
            Rectangle()
                .frame(width: 50, height: 20)
                .foregroundStyle(tag.color.color())
                .border(tag.color.color().appropriateTextColor)
        }
    }
}

#Preview("white_showColorString_true") {
    TagColorView(
        tag: Tag(title: "Sample Title", color: "#FFFFFF"),
        showColorString: true
    )
}

#Preview("white_showColorString_false") {
    TagColorView(
        tag: Tag(title: "Sample Title", color: "#FFFFFF"),
        showColorString: false
    )
}

#Preview("black_showColorString_true") {
    TagColorView(
        tag: Tag(title: "Sample Title", color: "#000000"),
        showColorString: true
    )
}

#Preview("black_showColorString_false") {
    TagColorView(
        tag: Tag(title: "Sample Title", color: "#000000"),
        showColorString: false
    )
}
