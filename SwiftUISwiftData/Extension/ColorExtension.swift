//
//  ColorExtension.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import SwiftUI

extension Color {
    func hexString(alpha: Bool = false) -> String {
        let components = rgbComponents()
        let alphaInt = alpha ? components.alpha : 1

        guard alpha else {
            return String(format: "#%02lX%02lX%02lX", components.red, components.green, components.blue)
        }
        return String(format: "#%02lX%02lX%02lX%02lX", components.red, components.green, components.blue, alphaInt)
    }

    /// # Reference
    /// [W3C](https://www.w3.org/TR/AERT/#color-contrast)
    var appropriateTextColor: Color {
        let components = rgbComponents()
        return ((((components.red * 299) + (components.green * 587) + (components.blue * 114)) / 1000) < 125) ? .white : .black
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

    private func rgbComponents() -> (red: Int, green: Int, blue: Int, alpha: Int) {
        guard let cgColor else { fatalError("no color") }
        let ciColor = CIColor(cgColor: cgColor)

        let red = lroundf(Float(ciColor.red) * 255)
        let green = lroundf(Float(ciColor.green) * 255)
        let blue = lroundf(Float(ciColor.blue) * 255)
        let alpha = lroundf(Float(ciColor.alpha) * 255)

        return (red, green, blue, alpha)
    }
}
