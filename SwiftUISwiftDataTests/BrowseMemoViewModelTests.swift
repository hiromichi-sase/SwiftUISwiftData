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
    func hasLink_reflectsUserDefaults() {
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setHasLink(true)
        #expect(dependency.testTarget.hasLink)

        dependency.userDefaultsRepository.setHasLink(false)
        #expect(!dependency.testTarget.hasLink)
    }

    @MainActor
    @Test
    func contentFontSize_reflectsUserDefaults() {
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        let value: Float = 16.0
        dependency.userDefaultsRepository.setContentFontSize(value)
        #expect(dependency.testTarget.contentFontSize == value)
    }

    @MainActor
    @Test
    func contentLineSpacing_reflectsUserDefaults() {
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        let value: Float = 2.0
        dependency.userDefaultsRepository.setContentLineSpacing(value)
        #expect(dependency.testTarget.contentLineSpacing == value)
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
    func isContentEmpty_true_whenMemoContentIsEmpty() {
        let dependency = Dependency(
            memo: Memo(title: "Title", content: "")
        )

        #expect(dependency.testTarget.isContentEmpty)
    }

    @MainActor
    @Test
    func isContentEmpty_false_whenMemoContentExists() {
        let dependency = Dependency(
            memo: Memo(title: "Title", content: "Hello")
        )

        #expect(!dependency.testTarget.isContentEmpty)
    }

    @MainActor
    @Test
    func displayContent_returnsNoContent_whenMemoContentIsEmpty() {
        let dependency = Dependency(
            memo: Memo(title: "Title", content: "")
        )

        #expect(dependency.testTarget.displayContent == CommonString.noContent)
    }

    @MainActor
    @Test
    func displayContent_returnsOriginalContent_whenMemoContentExists() {
        let content = "Hello, world"
        let dependency = Dependency(
            memo: Memo(title: "Title", content: content)
        )

        #expect(dependency.testTarget.displayContent == content)
    }

    @MainActor
    @Test
    func showingEditMemo_defaultIsFalse() {
        let dependency = Dependency()

        #expect(!dependency.testTarget.showingEditMemo)
    }

    @MainActor
    @Test
    func editButtonTapped_setsShowingEditMemoTrue() {
        let dependency = Dependency()

        dependency.testTarget.editButtonTapped()

        #expect(dependency.testTarget.showingEditMemo)
    }

    @MainActor
    @Test
    func dismissEdit_setsShowingEditMemoFalse() {
        let dependency = Dependency()

        dependency.testTarget.editButtonTapped()
        dependency.testTarget.dismissEdit()

        #expect(!dependency.testTarget.showingEditMemo)
    }

    @MainActor
    @Test
    func title_returnsMemoTitle() {
        let title = "Expected Title"
        let dependency = Dependency(
            memo: Memo(title: title, content: "Content")
        )

        #expect(dependency.testTarget.title == title)
    }

    @MainActor
    @Test
    func isProtected_returnsMemoProtected() {
        let dependency = Dependency(
            memo: Memo(
                title: "Title",
                content: "Content",
                protected: true
            )
        )

        #expect(dependency.testTarget.isProtected)
    }

    @MainActor
    @Test
    func tagsSortedByOrder_returnsTagsInOrder() {
        let tagB = Tag(title: "TagB", color: "0000FF", order: 2)
        let tagA = Tag(title: "TagA", color: "FF0000", order: 1)
        let memo = Memo(title: "Title", content: "Content")
        memo.tags = [tagB, tagA]

        let dependency = Dependency(memo: memo)
        let result = dependency.testTarget.tagsSortedByOrder

        #expect(result.count == 2)
        #expect(result[0].title == tagA.title)
        #expect(result[1].title == tagB.title)
    }
}

extension BrowseMemoViewModelTests {
    struct Dependency {
        let testTarget: BrowseMemoViewModel
        let userDefaultsRepository: UserDefaultsRepository
        private let support: TestDependencySupport

        @MainActor
        init(
            memo: Memo = Memo(
                title: "Test Memo Title",
                content: "Test Memo Content"
            )
        ) {
            let support = TestDependencySupport()
            self.support = support
            userDefaultsRepository = support.userDefaultsRepository
            testTarget = .init(
                memo: memo,
                userDefaultsRepository: userDefaultsRepository
            )
        }

        func removeUserDefaults() {
            support.removeUserDefaults()
        }
    }
}
