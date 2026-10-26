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
    @MainActor
    @Test
    func getHasLink() {
        let hasLink = true
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setHasLink(hasLink)
        #expect(dependency.testTarget.getHasLink() == hasLink)
    }

    @MainActor
    @Test
    func getContentFontSize() {
        let contentFontSize = Float(16.0)
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setContentFontSize(contentFontSize)
        #expect(dependency.testTarget.getContentFontSize() == contentFontSize)
    }

    @MainActor
    @Test
    func getContentLineSpacing() {
        let contentLineSpacing = Float.zero
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setContentLineSpacing(contentLineSpacing)
        #expect(dependency.testTarget.getContentLineSpacing() == contentLineSpacing)
    }

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

extension BrowseMemoViewModelTests {
    struct Dependency {
        let testTarget: BrowseMemoViewModel
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
