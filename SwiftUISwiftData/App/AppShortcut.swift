//
//  AppShortcut.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/10/16.
//

import UIKit

enum AppShortcut: String, CaseIterable {
    case addMemo = "com.hiro.swiftuiswiftdata.addMemo"

    init?(item: UIApplicationShortcutItem) {
        self.init(rawValue: item.type)
    }

    var type: String { rawValue }

    var title: String {
        switch self {
            case .addMemo:
                return "Add Memo"
        }
    }

    var iconType: UIApplicationShortcutIcon.IconType {
        switch self {
            case .addMemo:
                return .compose
        }
    }
}
