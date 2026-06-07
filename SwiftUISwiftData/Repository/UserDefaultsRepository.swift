//
//  UserDefaultsRepository.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/07.
//

import Foundation

class UserDefaultsRepository {

    static var test: UserDefaults = .init(suiteName: "test")!

    private enum Key: String, CaseIterable {
        case browseLink
        case contentFontSize
        case contentLineSpacing
        case titleLineLimit

        var defaultValue: Any? {
            switch self {
            case .browseLink:
                return true
            case .contentFontSize:
                return 16.0
            case .contentLineSpacing:
                return 1.5
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

    func getBrowseLink() -> Bool {
        userDefaults.bool(forKey: Key.browseLink.rawValue)
    }

    func setBrowseLink(_ value: Bool) {
        userDefaults.set(value, forKey: Key.browseLink.rawValue)
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
