//
//  AppDelegate.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/10/16.
//

import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        handleShortcutIfNeeded(options)

        let configuration = UISceneConfiguration(
            name: nil,
            sessionRole: connectingSceneSession.role
        )
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }

    private func handleShortcutIfNeeded(_ options: UIScene.ConnectionOptions) {
        guard let shortcutItem = options.shortcutItem else { return }
        _ = ShortcutDispatcher.handle(shortcutItem: shortcutItem)
    }
}
