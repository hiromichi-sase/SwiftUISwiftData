//
//  BrowseTagViewModelTests.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import Foundation
import Testing

@testable import SwiftUISwiftData

struct BrowseTagViewModelTests {
    @Test
    func getShowInfo() {
        let hasLink = false
        let dependency = Dependency()
        dependency.userDefaultsRepository.setShowInfo(hasLink)

        #expect(dependency.testTarget.getShowInfo() == hasLink)
        dependency.removeUserDefaults()
    }
}

extension BrowseTagViewModelTests {
    struct Dependency {
        let testTarget: BrowseTagViewModel
        private let userDefaults: UserDefaults
        let userDefaultsRepository: UserDefaultsRepository
        private static let suiteName: String = "Test"

        init() {
            guard let userDefaults = UserDefaults(suiteName: BrowseTagViewModelTests.Dependency.suiteName) else {
                fatalError("Could not create UserDefaults")
            }
            self.userDefaults = userDefaults
            userDefaultsRepository = .init(userDefaults: userDefaults)
            testTarget = .init(
                userDefaultsRepository: userDefaultsRepository
            )
        }

        func removeUserDefaults() {
            userDefaults.removePersistentDomain(forName: BrowseTagViewModelTests.Dependency.suiteName)
        }
    }
}
