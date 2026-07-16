//
//  StringExtension.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import SwiftUI

extension String {
    func color(colorSpace: String = CGColorSpace.sRGB as String, alpha: Bool = false) -> Color {
        let digit = alpha ? 8 : 6
        let patternString = "^#?[0-9a-fA-F]{\(digit)}$"

        do {
            let pattern = try Regex(patternString)
            guard wholeMatch(of: pattern) != nil else {
                fatalError("Failed to match pattern")
            }
        }
        catch {
            fatalError("Failed to match pattern")
        }

        let string = String(suffix(digit))

        let start = string.startIndex
        let i2 = string.index(start, offsetBy: 2)
        let i4 = string.index(start, offsetBy: 4)
        let i6 = string.index(start, offsetBy: 6)
        let i8 = string.index(start, offsetBy: 8, limitedBy: string.endIndex) ?? string.endIndex
        let redString = String(string[start ..< i2])
        let greenString = String(string[i2 ..< i4])
        let blueString = String(string[i4 ..< i6])
        let alphaString = alpha ? String(string[i6 ..< i8]) : "FF"

        guard let intRed = Int(redString, radix: 16) else {
            fatalError("Failed to get int value of red")
        }
        let red = CGFloat(intRed) / CGFloat(255.0)

        guard let intGreen = Int(greenString, radix: 16) else {
            fatalError("Failed to get int value of green")
        }
        let green = CGFloat(intGreen) / CGFloat(255.0)

        guard let intBlue = Int(blueString, radix: 16) else {
            fatalError("Failed to get int value of blue")
        }
        let blue = CGFloat(intBlue) / CGFloat(255.0)

        guard let intAlpha = Int(alphaString, radix: 16) else {
            fatalError("Failed to get int value of alpha")
        }
        let alpha = CGFloat(intAlpha) / CGFloat(255.0)

        guard let colorSpace = CGColorSpace(name: colorSpace as CFString),
            let cgColor = CGColor(colorSpace: colorSpace, components: [red, green, blue, alpha])
        else {
            fatalError()
        }
        return Color(cgColor: cgColor)
    }
}
