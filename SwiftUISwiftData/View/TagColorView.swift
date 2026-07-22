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

    var body: some View {
        if showColorString {
            Text(colorString)
                .frame(width: 90)
                .foregroundStyle(colorString.color().appropriateTextColor)
                .background(colorString.color())
                .border(colorString.color().tagBorderColor(colorScheme: colorScheme))
        }
        else {
            Rectangle()
                .frame(width: 50, height: 20)
                .foregroundStyle(colorString.color())
                .border(colorString.color().tagBorderColor(colorScheme: colorScheme))
        }
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
