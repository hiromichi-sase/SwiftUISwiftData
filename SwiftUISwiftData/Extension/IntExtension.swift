//
//  IntExtension.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/10/09.
//

import SwiftUI

extension Int {
    enum NounType {
        case memo
        case character
        case line

        var forms: (single: String, plural: String) {
            switch self {
                case .memo:
                    ("Memo", "Memos")
                case .character:
                    ("Character", "Characters")
                case .line:
                    ("Line", "Lines")
            }
        }
    }

    func nounText(for type: NounType) -> String {
        "\(self) \(self == 1 ? type.forms.single : type.forms.plural)"
    }
}
