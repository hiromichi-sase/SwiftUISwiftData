//
//  InfoText.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/12.
//

import SwiftUI

struct InfoText: View {
    enum Style {
        case createdAt
        case updatedAt
        case contentCharacters
        case contentLineNumbers

        var text: String {
            switch self {
                case .createdAt:
                    return "Created at"
                case .updatedAt:
                    return "Updated at"
                case .contentCharacters:
                    return "Content Characters"
                case .contentLineNumbers:
                    return "Content Line Numbers"
            }
        }
    }

    private let text: String
    private let style: Style

    init(_ date: Date?, style: Style) {
        self.style = style
        if let date {
            self.text = "\(style.text): \(date.formatted(date: .complete, time: .standard))"
        }
        else {
            self.text = ""
        }
    }

    init(_ intValue: Int, style: Style) {
        self.style = style
        self.text = "\(style.text): \(String(intValue))"
    }

    var body: some View {
        Text(text)
            .font(.system(size: 8.0))
            .multilineTextAlignment(.leading)
    }
}
