//
//  SelectTagViewModelTests.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import Foundation
import Testing

@testable import SwiftUISwiftData

struct SelectTagViewModelTests {
    @Test
    func getTitleLineLimit() {
        let titleLineLimit = 3
        let dependency = Dependency()
        dependency.userDefaultsRepository.setTitleLineLimit(titleLineLimit)

        #expect(dependency.testTarget.getTitleLineLimit() == titleLineLimit)
        dependency.removeUserDefaults()
    }

    @Test
    func getTitleFontSize() {
        let titleFontSize = Float(16.0)
        let dependency = Dependency()
        dependency.userDefaultsRepository.setTitleFontSize(titleFontSize)

        #expect(dependency.testTarget.getTitleFontSize() == titleFontSize)
        dependency.removeUserDefaults()
    }

    @Test
    func getTitleLineSpacing() {
        let titleLineSpacing = Float.zero
        let dependency = Dependency()
        dependency.userDefaultsRepository.setTitleLineSpacing(titleLineSpacing)

        #expect(dependency.testTarget.getTitleLineSpacing() == titleLineSpacing)
        dependency.removeUserDefaults()
    }
}

extension SelectTagViewModelTests {
    struct Dependency {
        let testTarget: SelectTagViewModel
        let tagRepository: TagRepository
        private let userDefaults: UserDefaults
        let userDefaultsRepository: UserDefaultsRepository
        private static let suiteName: String = "Test"

        init() {
            tagRepository = TagRepository(modelContainer: ModelContainerManager(isStoredInMemoryOnly: true).modelContainer)
            guard let userDefaults = UserDefaults(suiteName: SelectTagViewModelTests.Dependency.suiteName) else {
                fatalError("Could not create UserDefaults")
            }
            self.userDefaults = userDefaults
            userDefaultsRepository = .init(userDefaults: userDefaults)
            testTarget = .init(
                tagRepository: tagRepository,
                userDefaultsRepository: userDefaultsRepository
            )
        }

        func removeUserDefaults() {
            userDefaults.removePersistentDomain(forName: SelectTagViewModelTests.Dependency.suiteName)
        }
    }
}
