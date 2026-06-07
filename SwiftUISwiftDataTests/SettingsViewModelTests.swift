//
//  SettingsViewModelTests.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/08.
//

import Testing
@testable import SwiftUISwiftData
import Foundation

struct SettingsViewModelTests {

    @Test func hasLink()  {
        let hasLink = true
        let dependency = Dependency()
        dependency.testTarget.setHasLink(hasLink)

        #expect(dependency.testTarget.getHasLink() == hasLink)
        dependency.removeUserDefaults()
    }

    @Test func contentFontSize()  {
        let contentFontSize = Float(16.0)
        let dependency = Dependency()
        dependency.testTarget.setContentFontSize(contentFontSize)

        #expect(dependency.testTarget.getContentFontSize() == contentFontSize)
        dependency.removeUserDefaults()
    }

    @Test func contentLineSpacing()  {
        let contentLineSpacing = Float.zero
        let dependency = Dependency()
        dependency.testTarget.setContentLineSpacing(contentLineSpacing)

        #expect(dependency.testTarget.getContentLineSpacing() == contentLineSpacing)
        dependency.removeUserDefaults()
    }

    @Test func titleLineLimit()  {
        let titleLineLimit = 3
        let dependency = Dependency()
        dependency.testTarget.setTitleLineLimit(titleLineLimit)

        #expect(dependency.testTarget.getTitleLineLimit() == titleLineLimit)
        dependency.removeUserDefaults()
    }

}

extension SettingsViewModelTests {
    struct Dependency {
        let testTarget: SettingsViewModel
        let userDefaults: UserDefaults
        static let suiteName: String = "Test"

        init() {
            userDefaults = UserDefaults(suiteName: SettingsViewModelTests.Dependency.suiteName)!
            testTarget = .init(
                userDefaultsRepository: .init(userDefaults: userDefaults)
            )
        }

        func removeUserDefaults() {
            userDefaults.removePersistentDomain(forName: SettingsViewModelTests.Dependency.suiteName)
        }
    }
}

