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
        let pattern = "^#?[0-9a-fA-F]{\(digit)}$"

        guard range(of: pattern, options: .regularExpression) != nil else {
            fatalError("Failed to match pattern")
        }

        let hex = String(suffix(digit))
        let redString = String(hex.prefix(2))
        let greenString = String(hex.dropFirst(2).prefix(2))
        let blueString = String(hex.dropFirst(4).prefix(2))
        let alphaString = alpha ? String(hex.dropFirst(6).prefix(2)) : "FF"

        guard let intRed = Int(redString, radix: 16) else {
            fatalError("Failed to get int value of red")
        }
        guard let intGreen = Int(greenString, radix: 16) else {
            fatalError("Failed to get int value of green")
        }
        guard let intBlue = Int(blueString, radix: 16) else {
            fatalError("Failed to get int value of blue")
        }
        guard let intAlpha = Int(alphaString, radix: 16) else {
            fatalError("Failed to get int value of alpha")
        }

        let red = CGFloat(intRed) / 255.0
        let green = CGFloat(intGreen) / 255.0
        let blue = CGFloat(intBlue) / 255.0
        let alpha = CGFloat(intAlpha) / 255.0

        guard let colorSpace = CGColorSpace(name: colorSpace as CFString),
            let cgColor = CGColor(colorSpace: colorSpace, components: [red, green, blue, alpha])
        else {
            fatalError()
        }

        return Color(cgColor: cgColor)
    }
}
