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
                postOnMain(.closeAllPresentedViewsFromShortcut)
                postOnMain(.openAddMemoFromShortcut, delay: closeThenOpenDelay)
                return true
        }
    }

    private static func postOnMain(_ name: Notification.Name, delay: TimeInterval = .zero) {
        if delay == .zero {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: name, object: nil)
            }
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                NotificationCenter.default.post(name: name, object: nil)
            }
        }
    }
}
