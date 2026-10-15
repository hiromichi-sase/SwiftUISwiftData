//
//  SceneDelegate.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/10/16.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        let handled = ShortcutDispatcher.handle(shortcutItem: shortcutItem)
        completionHandler(handled)
    }
}
