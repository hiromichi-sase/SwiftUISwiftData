//
//  AttributedStringExtension.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/30.
//

import SwiftUI

extension AttributedString {
    func ranges<T: StringProtocol>(
        of stringToFind: T,
        options: String.CompareOptions = [],
        locale: Locale? = nil
    ) -> [Range<AttributedString.Index>] {
        var ranges: [Range<AttributedString.Index>] = []
        var substring = self[self.startIndex ..< self.endIndex]
        while let range = substring.range(of: stringToFind, options: options, locale: locale) {
            ranges.append(range)
            substring = self[range.upperBound...]
        }
        return ranges
    }
}
