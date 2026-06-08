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

    @Test func getContentFontSize()  {
        let contentFontSize = Float(16.0)
        let dependency = Dependency()
        dependency.testTarget.userDefaultsRepository.setContentFontSize(contentFontSize)

        #expect(dependency.testTarget.getContentFontSize() == contentFontSize)
        dependency.removeUserDefaults()
    }

    @Test func getContentLineSpacing()  {
        let contentLineSpacing = Float.zero
        let dependency = Dependency()
        dependency.testTarget.userDefaultsRepository.setContentLineSpacing(contentLineSpacing)

        #expect(dependency.testTarget.getContentLineSpacing() == contentLineSpacing)
        dependency.removeUserDefaults()
    }

}

extension PreviewMemoViewModelTests {
    struct Dependency {
        let testTarget: PreviewMemoViewModel
        let userDefaults: UserDefaults
        static let suiteName: String = "Test"

        init() {
            userDefaults = UserDefaults(suiteName: PreviewMemoViewModelTests.Dependency.suiteName)!
            testTarget = .init(
                userDefaultsRepository: .init(userDefaults: userDefaults)
            )
        }

        func removeUserDefaults() {
            userDefaults.removePersistentDomain(forName: PreviewMemoViewModelTests.Dependency.suiteName)
        }
    }
}
