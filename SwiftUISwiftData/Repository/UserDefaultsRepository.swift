//
//  UserDefaultsRepository.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/07.
//

import Foundation

class UserDefaultsRepository {

    private enum Key: String, CaseIterable {
        case hasLink
        case contentFontSize
        case contentLineSpacing
        case titleLineLimit

        var defaultValue: Any? {
            switch self {
            case .hasLink:
                return true
            case .contentFontSize:
                return 16.0
            case .contentLineSpacing:
                return Float.zero
            case .titleLineLimit:
                return 3
            }
        }
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults

        Key.allCases.forEach { key in
            guard let defaultValue = key.defaultValue else { return }
            userDefaults.register(defaults: [key.rawValue: defaultValue])
        }
    }

    func getHasLink() -> Bool {
        userDefaults.bool(forKey: Key.hasLink.rawValue)
    }

    func setHasLink(_ value: Bool) {
        userDefaults.set(value, forKey: Key.hasLink.rawValue)
    }

    func getContentFontSize() -> Float {
        userDefaults.float(forKey: Key.contentFontSize.rawValue)
    }

    func setContentFontSize(_ value: Float) {
        userDefaults.set(value, forKey: Key.contentFontSize.rawValue)
    }

    func getContentLineSpacing() -> Float {
        userDefaults.float(forKey: Key.contentLineSpacing.rawValue)
    }

    func setContentLineSpacing(_ value: Float) {
        userDefaults.set(value, forKey: Key.contentLineSpacing.rawValue)
    }

    func getTitleLineLimit() -> Int {
        userDefaults.integer(forKey: Key.titleLineLimit.rawValue)
    }

    func setTitleLineLimit(_ value: Int) {
        userDefaults.set(value, forKey: Key.titleLineLimit.rawValue)
    }

}
