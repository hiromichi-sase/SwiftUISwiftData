//
//  TagColorView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/20.
//

import SwiftUI

struct TagColorView: View {
    @Environment(\.colorScheme)
    private var colorScheme
    var colorString: String
    var showColorString: Bool

    private var tagColor: Color {
        colorString.color()
    }

    private var textColor: Color {
        tagColor.appropriateTextColor
    }

    var body: some View {
        if tagColor.needsBorder(colorScheme: colorScheme) {
            commonView()
                .border(textColor)
        }
        else {
            commonView()
        }
    }

    private func commonView() -> some View {
        Text(showColorString ? colorString : "")
            .frame(width: showColorString ? 90 : 50)
            .foregroundStyle(textColor)
            .background(tagColor)
    }
}

#Preview("white_showColorString_true") {
    TagColorView(
        colorString: "#FFFFFF",
        showColorString: true
    )
}

#Preview("white_showColorString_false") {
    TagColorView(
        colorString: "#FFFFFF",
        showColorString: false
    )
}

#Preview("black_showColorString_true") {
    TagColorView(
        colorString: "#000000",
        showColorString: true
    )
}

#Preview("black_showColorString_false") {
    TagColorView(
        colorString: "#000000",
        showColorString: false
    )
}
