//
//  UserDefaultsRepository.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/07.
//

import Foundation

final class UserDefaultsRepository {

    enum Key: String, CaseIterable {
        case hasLink
        case contentFontSize
        case contentLineSpacing
        case titleLineLimit
        case titleFontSize
        case titleLineSpacing
        case showDate

        var defaultValue: Any? {
            switch self {
            case .hasLink: true
            case .contentFontSize: Float(16.0)
            case .contentLineSpacing: Float.zero
            case .titleLineLimit: 3
            case .titleFontSize: Float(16.0)
            case .titleLineSpacing: Float.zero
            case .showDate: false
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
            case .showDate: nil
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
            case .showDate: nil
            }
        }
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
        defaultValues.forEach { key, value in
            userDefaults.register(defaults: [key.rawValue: value])
        }
    }

    private var defaultValues: [Key: Any] {
        Key.allCases.reduce(into: [:]) { result, key in
            result[key] = key.defaultValue
        }
    }

    var settingsChanged: Bool {
        var changedCount = Int.zero
        defaultValues.forEach { key, value in
            switch key {
            case .hasLink:
                changedCount += getHasLink() != (value as! Bool) ? 1 : .zero
            case .contentFontSize:
                changedCount += getContentFontSize() != (value as! Float) ? 1 : .zero
            case .contentLineSpacing:
                changedCount += getContentLineSpacing() != (value as! Float) ? 1 : .zero
            case .titleLineLimit:
                changedCount += getTitleLineLimit() != (value as! Int) ? 1 : .zero
            case .titleFontSize:
                changedCount += getTitleFontSize() != (value as! Float) ? 1 : .zero
            case .titleLineSpacing:
                changedCount += getTitleLineSpacing() != (value as! Float) ? 1 : .zero
            case .showDate:
                changedCount += getShowDate() != (value as! Bool) ? 1 : .zero
            }
        }
        return changedCount > .zero
    }

    private func range<T: Equatable>(for key: UserDefaultsRepository.Key) -> ClosedRange<T> {
        guard let minValue = key.minValue as! T?,
              let maxValue = key.maxValue as! T? else {
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

    func getShowDate() -> Bool {
        userDefaults.bool(forKey: Key.showDate.rawValue)
    }

    func setShowDate(_ value: Bool) {
        guard getShowDate() != value else { return }
        userDefaults.set(value, forKey: Key.showDate.rawValue)
    }
}
