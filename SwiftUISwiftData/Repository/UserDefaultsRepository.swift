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
        case defaultTagColor

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
                case .defaultTagColor: "#000000"
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
                case .defaultTagColor: nil
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
                case .defaultTagColor: nil
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

    private func setIfNeeded<T: Equatable>(_ value: T, for key: Key, current: T) {
        guard current != value else { return }
        userDefaults.set(value, forKey: key.rawValue)
    }

    private func hasChangedFromDefault<T: Equatable>(_ value: T, for key: Key, name: String) -> Bool {
        guard let defaultValue = key.defaultValue as? T else {
            fatalError("\(name) has no defaultValue")
        }
        return defaultValue != value
    }

    var settingsChanged: Bool {
        guard !hasLinkChanged(getHasLink()) else { return true }
        guard !contentFontSizeChanged(getContentFontSize()) else { return true }
        guard !contentLineSpacingChanged(getContentLineSpacing()) else { return true }
        guard !titleLineLimitChanged(getTitleLineLimit()) else { return true }
        guard !titleFontSizeChanged(getTitleFontSize()) else { return true }
        guard !titleLineSpacingChanged(getTitleLineSpacing()) else { return true }
        guard !showInfoChanged(getShowInfo()) else { return true }
        guard !showDivideKeywordsBySpaceChanged(getDivideKeywordsBySpace()) else { return true }
        guard !showDefaultTagColorChanged(getDefaultTagColor()) else { return true }
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
        guard let name = suiteName ?? Bundle.main.bundleIdentifier else { return }
        userDefaults.removePersistentDomain(forName: name)
    }

    func getHasLink() -> Bool {
        userDefaults.bool(forKey: Key.hasLink.rawValue)
    }

    func setHasLink(_ value: Bool) {
        setIfNeeded(value, for: .hasLink, current: getHasLink())
    }

    func getContentFontSize() -> Float {
        userDefaults.float(forKey: Key.contentFontSize.rawValue)
    }

    func setContentFontSize(_ value: Float) {
        setIfNeeded(value, for: .contentFontSize, current: getContentFontSize())
    }

    func getContentLineSpacing() -> Float {
        userDefaults.float(forKey: Key.contentLineSpacing.rawValue)
    }

    func setContentLineSpacing(_ value: Float) {
        setIfNeeded(value, for: .contentLineSpacing, current: getContentLineSpacing())
    }

    func getTitleLineLimit() -> Int {
        userDefaults.integer(forKey: Key.titleLineLimit.rawValue)
    }

    func setTitleLineLimit(_ value: Int) {
        setIfNeeded(value, for: .titleLineLimit, current: getTitleLineLimit())
    }

    func getTitleFontSize() -> Float {
        userDefaults.float(forKey: Key.titleFontSize.rawValue)
    }

    func setTitleFontSize(_ value: Float) {
        setIfNeeded(value, for: .titleFontSize, current: getTitleFontSize())
    }

    func getTitleLineSpacing() -> Float {
        userDefaults.float(forKey: Key.titleLineSpacing.rawValue)
    }

    func setTitleLineSpacing(_ value: Float) {
        setIfNeeded(value, for: .titleLineSpacing, current: getTitleLineSpacing())
    }

    func getShowInfo() -> Bool {
        userDefaults.bool(forKey: Key.showInfo.rawValue)
    }

    func setShowInfo(_ value: Bool) {
        setIfNeeded(value, for: .showInfo, current: getShowInfo())
    }

    func getDivideKeywordsBySpace() -> Bool {
        userDefaults.bool(forKey: Key.divideKeywordsBySpace.rawValue)
    }

    func setDivideKeywordsBySpace(_ value: Bool) {
        setIfNeeded(value, for: .divideKeywordsBySpace, current: getDivideKeywordsBySpace())
    }

    func getDefaultTagColor() -> String {
        guard let value = userDefaults.string(forKey: Key.defaultTagColor.rawValue) else {
            fatalError("defaultTagColor has no defaultValue")
        }
        return value
    }

    func setDefaultTagColor(_ value: String) {
        setIfNeeded(value, for: .defaultTagColor, current: getDefaultTagColor())
    }

    func hasLinkChanged(_ hasLink: Bool) -> Bool {
        hasChangedFromDefault(hasLink, for: .hasLink, name: "hasLink")
    }

    func contentFontSizeChanged(_ contentFontSize: Float) -> Bool {
        hasChangedFromDefault(contentFontSize, for: .contentFontSize, name: "contentFontSize")
    }

    func contentLineSpacingChanged(_ contentLineSpacing: Float) -> Bool {
        hasChangedFromDefault(contentLineSpacing, for: .contentLineSpacing, name: "contentLineSpacing")
    }

    func titleLineLimitChanged(_ titleLineLimit: Int) -> Bool {
        hasChangedFromDefault(titleLineLimit, for: .titleLineLimit, name: "titleLineLimit")
    }

    func titleFontSizeChanged(_ titleFontSize: Float) -> Bool {
        hasChangedFromDefault(titleFontSize, for: .titleFontSize, name: "titleFontSize")
    }

    func titleLineSpacingChanged(_ titleLineSpacing: Float) -> Bool {
        hasChangedFromDefault(titleLineSpacing, for: .titleLineSpacing, name: "titleLineSpacing")
    }

    func showInfoChanged(_ showInfo: Bool) -> Bool {
        hasChangedFromDefault(showInfo, for: .showInfo, name: "showInfo")
    }

    func showDivideKeywordsBySpaceChanged(_ showDivideKeywordsBySpace: Bool) -> Bool {
        hasChangedFromDefault(showDivideKeywordsBySpace, for: .divideKeywordsBySpace, name: "divideKeywordsBySpace")
    }

    func showDefaultTagColorChanged(_ showDefaultTagColor: String) -> Bool {
        hasChangedFromDefault(showDefaultTagColor, for: .defaultTagColor, name: "defaultTagColor")
    }
}
