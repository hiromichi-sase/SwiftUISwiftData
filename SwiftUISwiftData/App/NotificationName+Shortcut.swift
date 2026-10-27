//
//  NotificationName+Shortcut.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/10/16.
//

import Foundation

extension Notification.Name {
    private enum ShortcutName {
        static let openAddMemo = "openAddMemoFromShortcut"
        static let closeAllPresentedViews = "closeAllPresentedViewsFromShortcut"
    }

    static let openAddMemoFromShortcut = Notification.Name(ShortcutName.openAddMemo)
    static let closeAllPresentedViewsFromShortcut = Notification.Name(ShortcutName.closeAllPresentedViews)
}
