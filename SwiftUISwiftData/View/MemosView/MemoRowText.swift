//
//  MemoRowText.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/23.
//

import SwiftUI

struct MemoRowText: View {
    let memo: Memo
    let titleLineLimit: Int
    let titleFontSize: Float
    let titleLineSpacing: Float
    var keywordsForFiltering: [String] = []

    var body: some View {
        Text(memo.title.isEmpty ? AttributedString(CommonString.noTitle) : attributedTitle)
            .foregroundStyle(memo.title.isEmpty ? .secondary : .primary)
            .lineLimit(titleLineLimit)
            .font(.system(size: CGFloat(titleFontSize)))
            .lineSpacing(CGFloat(titleLineSpacing))
    }

    private var attributedTitle: AttributedString {
        var attributedTitle = AttributedString(memo.title)

        for keyword in keywordsForFiltering {
            let ranges = attributedTitle.ranges(of: keyword, options: [.caseInsensitive, .literal])
            for range in ranges {
                attributedTitle[range].font = .system(size: CGFloat(titleFontSize), weight: .bold)
                attributedTitle[range].backgroundColor = .quaternaryLabel
            }
        }

        return attributedTitle
    }
}
