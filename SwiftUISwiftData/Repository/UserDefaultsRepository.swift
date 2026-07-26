//
//  UserDefaultsRepository.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/07.
//

import Foundation

final class UserDefaultsRepository {
    private enum Key: String, CaseIterable {
        case hasLink
        case contentFontSize
        case contentLineSpacing
        case titleLineLimit
        case titleFontSize
        case titleLineSpacing
        case showInfo
        case divideKeywordsBySpace

        var defaultValue: Any? {
            switch self {
                case .hasLink: true
                case .contentFontSize: Float(16.0)
                case .contentLineSpacing: Float.zero
                case .titleLineLimit: 3
                case .titleFontSize: Float(16.0)
                case .titleLineSpacing: Float.zero
                case .showInfo: false
                case .divideKeywordsBySpace: false
            }
        }

        var maxValue: Any? {
            switch self {
                case .hasLink: nil
                case .contentFontSize: Float(100.0)
                case .contentLineSpacing: Float(10.0)
                case .titleLineLimit: 5
                case .titleFontSize: Float(100.0)
                case .titleLineSpacing: Float(10.0)
                case .showInfo: nil
                case .divideKeywordsBySpace: nil
            }
        }

        var minValue: Any? {
            switch self {
                case .hasLink: nil
                case .contentFontSize: Float(5.0)
                case .contentLineSpacing: Float.zero
                case .titleLineLimit: 1
                case .titleFontSize: Float(5.0)
                case .titleLineSpacing: Float.zero
                case .showInfo: nil
                case .divideKeywordsBySpace: nil
            }
        }
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
        for (key, value) in defaultValues {
            userDefaults.register(defaults: [key.rawValue: value])
        }
    }

    private var defaultValues: [Key: Any] {
        Key.allCases.reduce(into: [:]) { result, key in
            result[key] = key.defaultValue
        }
    }

    var settingsChanged: Bool {
        guard !hasLinkChanged(getHasLink()) else { return true }
        guard !contentFontSizeChanged(getContentFontSize()) else { return true }
        guard !contentLineSpacingChanged(getContentLineSpacing()) else { return true }
        guard !titleLineLimitChanged(getTitleLineLimit()) else { return true }
        guard !titleFontSizeChanged(getTitleFontSize()) else { return true }
        guard !titleLineSpacingChanged(getTitleLineSpacing()) else { return true }
        guard !showInfoChanged(getShowInfo()) else { return true }
        return false
    }

    private func range<T: Equatable>(for key: UserDefaultsRepository.Key) -> ClosedRange<T> {
        guard let minValue = key.minValue as? T,
            let maxValue = key.maxValue as? T
        else {
            fatalError("\(key) has no minValue or maxValue")
        }
        return minValue ... maxValue
    }

    var contentFontSizeRange: ClosedRange<Float> {
        range(for: .contentFontSize) as ClosedRange<Float>
    }

    var contentLineSpacingRange: ClosedRange<Float> {
        range(for: .contentLineSpacing) as ClosedRange<Float>
    }

    var titleLineLimitRange: ClosedRange<Int> {
        range(for: .titleLineLimit) as ClosedRange<Int>
    }

    var titleFontSizeRange: ClosedRange<Float> {
        range(for: .titleFontSize) as ClosedRange<Float>
    }

    var titleLineSpacingRange: ClosedRange<Float> {
        range(for: .titleLineSpacing) as ClosedRange<Float>
    }

    func reset(suiteName: String? = nil) {
        let divideKeywordsBySpace = getDivideKeywordsBySpace()

        guard let name = suiteName ?? Bundle.main.bundleIdentifier else { return }
        userDefaults.removePersistentDomain(forName: name)

        setDivideKeywordsBySpace(divideKeywordsBySpace)
    }

    func getHasLink() -> Bool {
        userDefaults.bool(forKey: Key.hasLink.rawValue)
    }

    func setHasLink(_ value: Bool) {
        guard getHasLink() != value else { return }
        userDefaults.set(value, forKey: Key.hasLink.rawValue)
    }

    func getContentFontSize() -> Float {
        userDefaults.float(forKey: Key.contentFontSize.rawValue)
    }

    func setContentFontSize(_ value: Float) {
        guard getContentFontSize() != value else { return }
        userDefaults.set(value, forKey: Key.contentFontSize.rawValue)
    }

    func getContentLineSpacing() -> Float {
        userDefaults.float(forKey: Key.contentLineSpacing.rawValue)
    }

    func setContentLineSpacing(_ value: Float) {
        guard getContentLineSpacing() != value else { return }
        userDefaults.set(value, forKey: Key.contentLineSpacing.rawValue)
    }

    func getTitleLineLimit() -> Int {
        userDefaults.integer(forKey: Key.titleLineLimit.rawValue)
    }

    func setTitleLineLimit(_ value: Int) {
        guard getTitleLineLimit() != value else { return }
        userDefaults.set(value, forKey: Key.titleLineLimit.rawValue)
    }

    func getTitleFontSize() -> Float {
        userDefaults.float(forKey: Key.titleFontSize.rawValue)
    }

    func setTitleFontSize(_ value: Float) {
        guard getTitleFontSize() != value else { return }
        userDefaults.set(value, forKey: Key.titleFontSize.rawValue)
    }

    func getTitleLineSpacing() -> Float {
        userDefaults.float(forKey: Key.titleLineSpacing.rawValue)
    }

    func setTitleLineSpacing(_ value: Float) {
        guard getTitleLineSpacing() != value else { return }
        userDefaults.set(value, forKey: Key.titleLineSpacing.rawValue)
    }

    func getShowInfo() -> Bool {
        userDefaults.bool(forKey: Key.showInfo.rawValue)
    }

    func setShowInfo(_ value: Bool) {
        guard getShowInfo() != value else { return }
        userDefaults.set(value, forKey: Key.showInfo.rawValue)
    }

    func getDivideKeywordsBySpace() -> Bool {
        userDefaults.bool(forKey: Key.divideKeywordsBySpace.rawValue)
    }

    func setDivideKeywordsBySpace(_ value: Bool) {
        guard getDivideKeywordsBySpace() != value else { return }
        userDefaults.set(value, forKey: Key.divideKeywordsBySpace.rawValue)
    }

    func hasLinkChanged(_ hasLink: Bool) -> Bool {
        guard let value = Key.hasLink.defaultValue as? Bool else {
            fatalError("hasLink has no defaultValue")
        }
        return value != hasLink
    }

    func contentFontSizeChanged(_ contentFontSize: Float) -> Bool {
        guard let value = Key.contentFontSize.defaultValue as? Float else {
            fatalError("contentFontSize has no defaultValue")
        }
        return value != contentFontSize
    }

    func contentLineSpacingChanged(_ contentLineSpacing: Float) -> Bool {
        guard let value = Key.contentLineSpacing.defaultValue as? Float else {
            fatalError("contentLineSpacing has no defaultValue")
        }
        return value != contentLineSpacing
    }

    func titleLineLimitChanged(_ titleLineLimit: Int) -> Bool {
        guard let value = Key.titleLineLimit.defaultValue as? Int else {
            fatalError("titleLineLimit has no defaultValue")
        }
        return value != titleLineLimit
    }

    func titleFontSizeChanged(_ titleFontSize: Float) -> Bool {
        guard let value = Key.titleFontSize.defaultValue as? Float else {
            fatalError("titleFontSize has no defaultValue")
        }
        return value != titleFontSize
    }

    func titleLineSpacingChanged(_ titleLineSpacing: Float) -> Bool {
        guard let value = Key.titleLineSpacing.defaultValue as? Float else {
            fatalError("titleLineSpacing has no defaultValue")
        }
        return value != titleLineSpacing
    }

    func showInfoChanged(_ showInfo: Bool) -> Bool {
        guard let value = Key.showInfo.defaultValue as? Bool else {
            fatalError("showInfo has no defaultValue")
        }
        return value != showInfo
    }
}
