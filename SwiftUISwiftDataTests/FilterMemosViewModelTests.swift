//
//  FilterMemosViewModelTests.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/24.
//

import Foundation
import Testing

@testable import SwiftUISwiftData

struct FilterMemosViewModelTests {
    @Test
    func divideKeywordsBySpace() {
        let dependency = Dependency()
        defer {
            dependency.removeUserDefaults()
        }

        let defaultValue: Bool = false
        dependency.testTarget.setDivideKeywordsBySpace(defaultValue)
        #expect(dependency.testTarget.getDivideKeywordsBySpace() == defaultValue)
    }
}

extension FilterMemosViewModelTests {
    struct Dependency {
        let testTarget: FilterMemosViewModel
        let tagRepository: TagRepository
        private let userDefaults: UserDefaults
        private static let suiteName: String = "Test"

        init() {
            tagRepository = .init(modelContainer: ModelContainerManager(isStoredInMemoryOnly: true).modelContainer)
            guard let userDefaults = UserDefaults(suiteName: FilterMemosViewModelTests.Dependency.suiteName) else {
                fatalError("Could not create UserDefaults")
            }
            self.userDefaults = userDefaults
            testTarget = .init(
                tagRepository: tagRepository,
                userDefaultsRepository: .init(userDefaults: userDefaults),
                suiteName: FilterMemosViewModelTests.Dependency.suiteName,
            )
        }

        func removeUserDefaults() {
            userDefaults.removePersistentDomain(forName: FilterMemosViewModelTests.Dependency.suiteName)
        }
    }
}
