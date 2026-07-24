//
//  ColorExtension.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import SwiftUI

extension Color {
    func hexString(alpha: Bool = false) -> String {
        guard let cgColor else { fatalError("no color") }
        let ciColor = CIColor(cgColor: cgColor)
        let redInt = lroundf(Float(ciColor.red) * 255)
        let greenInt = lroundf(Float(ciColor.green) * 255)
        let blueInt = lroundf(Float(ciColor.blue) * 255)
        let alphaInt = alpha ? lroundf(Float(ciColor.alpha) * 255) : 1

        guard alpha else {
            return String(format: "#%02lX%02lX%02lX", redInt, greenInt, blueInt)
        }
        return String(format: "#%02lX%02lX%02lX%02lX", redInt, greenInt, blueInt, alphaInt)
    }

    /// # Reference
    /// [W3C](https://www.w3.org/TR/AERT/#color-contrast)
    var appropriateTextColor: Color {
        guard let cgColor else { fatalError("no color") }
        let ciColor = CIColor(cgColor: cgColor)
        let redInt = lroundf(Float(ciColor.red) * 255)
        let greenInt = lroundf(Float(ciColor.green) * 255)
        let blueInt = lroundf(Float(ciColor.blue) * 255)

        return ((((redInt * 299) + (greenInt * 587) + (blueInt * 114)) / 1000) < 125) ? .white : .black
    }

    func needsBorder(colorScheme: ColorScheme) -> Bool {
        if colorScheme == .light, appropriateTextColor == .black {
            true
        }
        else if colorScheme == .dark, appropriateTextColor == .white {
            true
        }
        else {
            false
        }
    }
}
