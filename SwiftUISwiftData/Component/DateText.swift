//
//  DateText.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/12.
//

import SwiftUI

struct DateText: View {
    enum style {
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
    }

    private let text: String

    init(_ date: Date?, style: style) {
        if let date {
            self.text = "\(style.text): \(date.formatted(date: .complete, time: .standard))"
        } else {
            self.text = ""
        }
    }

    var body: some View {
        Text(text)
            .font(.system(size: 8.0))
    }
}
