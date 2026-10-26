//
//  SelectTagViewModelTests.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import Foundation
import SwiftData
import Testing

@testable import SwiftUISwiftData

struct SelectTagViewModelTests {
    @MainActor
    @Test
    func getTitleLineLimit() {
        let titleLineLimit = 3
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setTitleLineLimit(titleLineLimit)
        #expect(dependency.testTarget.getTitleLineLimit() == titleLineLimit)
    }

    @MainActor
    @Test
    func getTitleFontSize() {
        let titleFontSize = Float(16.0)
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setTitleFontSize(titleFontSize)
        #expect(dependency.testTarget.getTitleFontSize() == titleFontSize)
    }

    @MainActor
    @Test
    func getTitleLineSpacing() {
        let titleLineSpacing = Float.zero
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setTitleLineSpacing(titleLineSpacing)
        #expect(dependency.testTarget.getTitleLineSpacing() == titleLineSpacing)
    }
}

extension SelectTagViewModelTests {
    struct Dependency {
        let testTarget: SelectTagViewModel
        let tagRepository: TagRepository
        let userDefaultsRepository: UserDefaultsRepository
        private let support: TestDependencySupport

        @MainActor
        init() {
            let support = TestDependencySupport()
            self.support = support
            userDefaultsRepository = support.userDefaultsRepository

            let modelContainerManager = ModelContainerManager(isStoredInMemoryOnly: true)
            tagRepository = TagRepository(modelContext: modelContainerManager.modelContainer.mainContext)

            testTarget = .init(
                tagRepository: tagRepository,
                userDefaultsRepository: userDefaultsRepository
            )
        }

        func removeUserDefaults() {
            support.removeUserDefaults()
        }
    }
}
