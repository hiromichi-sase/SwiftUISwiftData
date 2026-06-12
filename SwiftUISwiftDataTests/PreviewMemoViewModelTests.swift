//
//  PreviewMemoViewModelTests.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/08.
//

import Testing
@testable import SwiftUISwiftData
import Foundation

struct PreviewMemoViewModelTests {

    @Test func getContentFontSize() {
        let contentFontSize = Float(16.0)
        let dependency = Dependency()
        dependency.userDefaultsRepository.setContentFontSize(contentFontSize)

        #expect(dependency.testTarget.getContentFontSize() == contentFontSize)
        dependency.removeUserDefaults()
    }

    @Test func getContentLineSpacing() {
        let contentLineSpacing = Float.zero
        let dependency = Dependency()
        dependency.userDefaultsRepository.setContentLineSpacing(contentLineSpacing)

        #expect(dependency.testTarget.getContentLineSpacing() == contentLineSpacing)
        dependency.removeUserDefaults()
    }

}

extension PreviewMemoViewModelTests {
    struct Dependency {
        let testTarget: PreviewMemoViewModel
        private let userDefaults: UserDefaults
        let userDefaultsRepository: UserDefaultsRepository
        private static let suiteName: String = "Test"

        init() {
            userDefaults = UserDefaults(suiteName: PreviewMemoViewModelTests.Dependency.suiteName)!
            userDefaultsRepository = .init(userDefaults: userDefaults)
            testTarget = .init(
                userDefaultsRepository: userDefaultsRepository
            )
        }

        func removeUserDefaults() {
            userDefaults.removePersistentDomain(forName: PreviewMemoViewModelTests.Dependency.suiteName)
        }
    }
}
