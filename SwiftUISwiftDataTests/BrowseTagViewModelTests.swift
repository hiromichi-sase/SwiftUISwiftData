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
        #expect(dependency.testTarget.showInfo == hasLink)
    }

    @MainActor
    @Test
    func showInfo_reflectsUserDefaults() {
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setShowInfo(true)
        #expect(dependency.testTarget.showInfo)

        dependency.userDefaultsRepository.setShowInfo(false)
        #expect(!dependency.testTarget.showInfo)
    }

    @MainActor
    @Test
    func editButtonTapped_setsShowingEditMemoTrue() {
        let dependency = Dependency()

        dependency.testTarget.editButtonTapped()

        #expect(dependency.testTarget.showingEditTag)
    }

    @MainActor
    @Test
    func dismissEdit_setsShowingEditMemoFalse() {
        let dependency = Dependency()

        dependency.testTarget.editButtonTapped()
        dependency.testTarget.dismissEdit()

        #expect(!dependency.testTarget.showingEditTag)
    }

    @MainActor
    @Test
    func title_returnsTagTitle() {
        let title = "Expected Title"
        let dependency = Dependency(
            tag: Tag(title: title, color: "#000000")
        )

        #expect(dependency.testTarget.tag.title == title)
    }
}

extension BrowseTagViewModelTests {
    struct Dependency {
        let testTarget: BrowseTagViewModel
        let userDefaultsRepository: UserDefaultsRepository
        private let support: TestDependencySupport

        @MainActor
        init(
            tag: Tag = Tag(
                title: "Test Title",
                color: "#000000"
            ),
        ) {
            let support = TestDependencySupport()
            self.support = support
            userDefaultsRepository = support.userDefaultsRepository
            testTarget = .init(
                tag: tag,
                userDefaultsRepository: userDefaultsRepository
            )
        }

        func removeUserDefaults() {
            support.removeUserDefaults()
        }
    }
}
