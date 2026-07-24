//
//  SettingsViewModelTests.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/08.
//

import Foundation
import Testing

@testable import SwiftUISwiftData

struct SettingsViewModelTests {
    @Test
    func hasLink() {
        let dependency = Dependency()
        defer {
            dependency.removeUserDefaults()
        }

        let defaultValue: Bool = true
        dependency.testTarget.setHasLink(defaultValue)
        #expect(dependency.testTarget.getHasLink() == defaultValue)
    }

    @Test
    func contentFontSize() {
        let dependency = Dependency()
        defer {
            dependency.removeUserDefaults()
        }

        let defaultValue: Float = 16.0
        dependency.testTarget.setContentFontSize(defaultValue)
        #expect(dependency.testTarget.getContentFontSize() == defaultValue)

        let lowerBound: Float = 5.0
        let upperBound: Float = 100.0
        #expect(dependency.testTarget.contentFontSizeRange == lowerBound ... upperBound)
    }

    @Test
    func contentLineSpacing() {
        let dependency = Dependency()
        defer {
            dependency.removeUserDefaults()
        }

        let defaultValue: Float = .zero
        dependency.testTarget.setContentLineSpacing(defaultValue)
        #expect(dependency.testTarget.getContentLineSpacing() == defaultValue)

        let lowerBound: Float = .zero
        let upperBound: Float = 10.0
        #expect(dependency.testTarget.contentLineSpacingRange == lowerBound ... upperBound)
    }

    @Test
    func titleLineLimit() {
        let dependency = Dependency()
        defer {
            dependency.removeUserDefaults()
        }

        let defaultValue: Int = 3
        dependency.testTarget.setTitleLineLimit(defaultValue)
        #expect(dependency.testTarget.getTitleLineLimit() == defaultValue)

        let lowerBound: Int = 1
        let upperBound: Int = 5
        #expect(dependency.testTarget.titleLineLimitRange == lowerBound ... upperBound)
    }

    @Test
    func titleFontSize() {
        let dependency = Dependency()
        defer {
            dependency.removeUserDefaults()
        }

        let defaultValue: Float = 16.0
        dependency.testTarget.setTitleFontSize(defaultValue)
        #expect(dependency.testTarget.getTitleFontSize() == defaultValue)

        let lowerBound: Float = 5.0
        let upperBound: Float = 100.0
        #expect(dependency.testTarget.titleFontSizeRange == lowerBound ... upperBound)
    }

    @Test
    func titleLineSpacing() {
        let dependency = Dependency()
        defer {
            dependency.removeUserDefaults()
        }

        let defaultValue: Float = .zero
        dependency.testTarget.setTitleLineSpacing(defaultValue)
        #expect(dependency.testTarget.getTitleLineSpacing() == defaultValue)

        let lowerBound: Float = .zero
        let upperBound: Float = 10.0
        #expect(dependency.testTarget.titleLineSpacingRange == lowerBound ... upperBound)
    }

    @Test
    func showInfo() {
        let dependency = Dependency()
        defer {
            dependency.removeUserDefaults()
        }

        let defaultValue: Bool = false
        dependency.testTarget.setShowInfo(defaultValue)
        #expect(dependency.testTarget.getShowInfo() == defaultValue)
    }

    @Test
    func reset() {
        let dependency = Dependency()
        defer {
            dependency.removeUserDefaults()
        }

        dependency.testTarget.setHasLink(false)
        dependency.testTarget.setContentFontSize(30.0)
        dependency.testTarget.setContentLineSpacing(5.0)
        dependency.testTarget.setTitleLineLimit(5)
        dependency.testTarget.setTitleFontSize(30.0)
        dependency.testTarget.setTitleLineSpacing(5.0)
        dependency.testTarget.setShowInfo(true)
        #expect(dependency.testTarget.settingsChanged)

        dependency.testTarget.reset()
        #expect(!dependency.testTarget.settingsChanged)
    }
}

extension SettingsViewModelTests {
    struct Dependency {
        let testTarget: SettingsViewModel
        private let userDefaults: UserDefaults
        private static let suiteName: String = "Test"

        init() {
            guard let userDefaults = UserDefaults(suiteName: SettingsViewModelTests.Dependency.suiteName) else {
                fatalError("Could not create UserDefaults")
            }
            self.userDefaults = userDefaults
            testTarget = .init(
                userDefaultsRepository: .init(userDefaults: userDefaults),
                suiteName: SettingsViewModelTests.Dependency.suiteName
            )
        }

        func removeUserDefaults() {
            userDefaults.removePersistentDomain(forName: SettingsViewModelTests.Dependency.suiteName)
        }
    }
}
