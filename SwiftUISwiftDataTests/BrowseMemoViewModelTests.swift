//
//  BrowseMemoViewModelTests.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/08.
//

import Testing
@testable import SwiftUISwiftData
import Foundation

struct BrowseMemoViewModelTests {

    @Test func getHasLink()  {
        let hasLink = true
        let dependency = Dependency()
        dependency.userDefaultsRepository.setHasLink(hasLink)

        #expect(dependency.testTarget.getHasLink() == hasLink)
        dependency.removeUserDefaults()
    }

    @Test func getContentFontSize()  {
        let contentFontSize = Float(16.0)
        let dependency = Dependency()
        dependency.userDefaultsRepository.setContentFontSize(contentFontSize)

        #expect(dependency.testTarget.getContentFontSize() == contentFontSize)
        dependency.removeUserDefaults()
    }

    @Test func getContentLineSpacing()  {
        let contentLineSpacing = Float.zero
        let dependency = Dependency()
        dependency.userDefaultsRepository.setContentLineSpacing(contentLineSpacing)

        #expect(dependency.testTarget.getContentLineSpacing() == contentLineSpacing)
        dependency.removeUserDefaults()
    }

}

extension BrowseMemoViewModelTests {
    struct Dependency {
        let testTarget: BrowseMemoViewModel
        let userDefaults: UserDefaults
        let userDefaultsRepository: UserDefaultsRepository
        static let suiteName: String = "Test"

        init() {
            userDefaults = UserDefaults(suiteName: BrowseMemoViewModelTests.Dependency.suiteName)!
            userDefaultsRepository = .init(userDefaults: userDefaults)
            testTarget = .init(
                memoRepository: .init(modelContainer: ModelContainerManager(isStoredInMemoryOnly: true).modelContainer),
                userDefaultsRepository: userDefaultsRepository
            )
        }

        func removeUserDefaults() {
            userDefaults.removePersistentDomain(forName: BrowseMemoViewModelTests.Dependency.suiteName)
        }
    }
}
