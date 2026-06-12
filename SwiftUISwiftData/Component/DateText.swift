//
//  DateText.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/12.
//

import SwiftUI

struct DateText: View {
    enum Style {
        case createdAt
        case updatedAt

        var text: String {
            switch self {
            case .createdAt:
                return "Created at"
            case .updatedAt:
                return "Updated at"
            }
        }

        var alignment: TextAlignment {
            switch self {
            case .createdAt:
                return .leading
            case .updatedAt:
                return .trailing
            }
        }
    }

    private let text: String
    private let style: Style

    init(_ date: Date?, style: Style) {
        self.style = style
        if let date {
            self.text = "\(style.text): \(date.formatted(date: .complete, time: .standard))"
        } else {
            self.text = ""
        }
    }

    var body: some View {
        Text(text)
            .font(.system(size: 8.0))
            .multilineTextAlignment(self.style.alignment)
    }
}
