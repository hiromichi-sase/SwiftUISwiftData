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
    var searchWords: [String] = []

    var body: some View {
        Text(tag.title.isEmpty ? AttributedString(CommonString.noTitle) : attributedTitle)
            .foregroundStyle(tag.title.isEmpty ? .secondary : .primary)
            .lineLimit(titleLineLimit)
            .font(.system(size: CGFloat(titleFontSize)))
            .lineSpacing(CGFloat(titleLineSpacing))
    }

    private var attributedTitle: AttributedString {
        var attributedTitle = AttributedString(tag.title)

        for word in searchWords {
            let ranges = attributedTitle.ranges(of: word, options: [.caseInsensitive, .literal])
            for range in ranges {
                attributedTitle[range].font = .system(size: CGFloat(titleFontSize), weight: .bold)
                attributedTitle[range].backgroundColor = .quaternaryLabel
            }
        }

        return attributedTitle
    }
}
