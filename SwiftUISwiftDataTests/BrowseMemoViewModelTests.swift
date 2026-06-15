//
//  BrowseMemoViewModelTests.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/08.
//

import Foundation
import Testing
@testable import SwiftUISwiftData

struct BrowseMemoViewModelTests {
    @Test
    func getHasLink() {
        let hasLink = true
        let dependency = Dependency()
        dependency.userDefaultsRepository.setHasLink(hasLink)

        #expect(dependency.testTarget.getHasLink() == hasLink)
        dependency.removeUserDefaults()
    }

    @Test
    func getContentFontSize() {
        let contentFontSize = Float(16.0)
        let dependency = Dependency()
        dependency.userDefaultsRepository.setContentFontSize(contentFontSize)

        #expect(dependency.testTarget.getContentFontSize() == contentFontSize)
        dependency.removeUserDefaults()
    }

    @Test
    func getContentLineSpacing() {
        let contentLineSpacing = Float.zero
        let dependency = Dependency()
        dependency.userDefaultsRepository.setContentLineSpacing(contentLineSpacing)

        #expect(dependency.testTarget.getContentLineSpacing() == contentLineSpacing)
        dependency.removeUserDefaults()
    }

    @Test
    func getShowDate() {
        let hasLink = false
        let dependency = Dependency()
        dependency.userDefaultsRepository.setShowDate(hasLink)

        #expect(dependency.testTarget.getShowDate() == hasLink)
        dependency.removeUserDefaults()
    }
}

extension BrowseMemoViewModelTests {
    struct Dependency {
        let testTarget: BrowseMemoViewModel
        private let userDefaults: UserDefaults
        let userDefaultsRepository: UserDefaultsRepository
        private static let suiteName: String = "Test"

        init() {
            guard let userDefaults = UserDefaults(suiteName: BrowseMemoViewModelTests.Dependency.suiteName) else {
                fatalError("Could not create UserDefaults")
            }
            self.userDefaults = userDefaults
            userDefaultsRepository = .init(userDefaults: userDefaults)
            testTarget = .init(
                userDefaultsRepository: userDefaultsRepository
            )
        }

        func removeUserDefaults() {
            userDefaults.removePersistentDomain(forName: BrowseMemoViewModelTests.Dependency.suiteName)
        }
    }
}
