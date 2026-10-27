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
    @MainActor
    @Test
    func getShowInfo() {
        let hasLink = false
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setShowInfo(hasLink)
        #expect(dependency.testTarget.getShowInfo() == hasLink)
    }
}

extension BrowseTagViewModelTests {
    struct Dependency {
        let testTarget: BrowseTagViewModel
        let userDefaultsRepository: UserDefaultsRepository
        private let support: TestDependencySupport

        @MainActor
        init() {
            let support = TestDependencySupport()
            self.support = support
            userDefaultsRepository = support.userDefaultsRepository
            testTarget = .init(userDefaultsRepository: userDefaultsRepository)
        }

        func removeUserDefaults() {
            support.removeUserDefaults()
        }
    }
}
