//
//  ShortcutDispatcher.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/10/16.
//

import Foundation
import UIKit

enum ShortcutDispatcher {
    private static let closeThenOpenDelay: TimeInterval = 0.3

    static func handle(shortcutItem: UIApplicationShortcutItem) -> Bool {
        guard let shortcut = AppShortcut(item: shortcutItem) else { return false }

        switch shortcut {
            case .addMemo:
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .closeAllPresentedViewsFromShortcut, object: nil)
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + closeThenOpenDelay) {
                    NotificationCenter.default.post(name: .openAddMemoFromShortcut, object: nil)
                }

                return true
        }
    }
}
