//
//  PreviewMemoViewModelTests.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/08.
//

import Foundation
import Testing

@testable import SwiftUISwiftData

struct PreviewMemoViewModelTests {
    @MainActor
    @Test
    func contentFontSize() {
        let contentFontSize = Float(16.0)
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setContentFontSize(contentFontSize)
        #expect(dependency.testTarget.contentFontSize == contentFontSize)
    }

    @MainActor
    @Test
    func contentLineSpacing() {
        let contentLineSpacing = Float.zero
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setContentLineSpacing(contentLineSpacing)
        #expect(dependency.testTarget.contentLineSpacing == contentLineSpacing)
    }

    @MainActor
    @Test
    func displayContent_whenContentIsEmpty_returnsNoContent() {
        let dependency = Dependency(
            memo: Memo(title: "Title", content: "")
        )
        defer { dependency.removeUserDefaults() }

        #expect(dependency.testTarget.isContentEmpty)
        #expect(dependency.testTarget.displayContent == CommonString.noContent)
    }

    @MainActor
    @Test
    func displayContent_whenContentExists_returnsOriginalContent() {
        let content = "Hello"
        let dependency = Dependency(
            memo: Memo(title: "Title", content: content)
        )
        defer { dependency.removeUserDefaults() }

        #expect(!dependency.testTarget.isContentEmpty)
        #expect(dependency.testTarget.displayContent == content)
    }
}

extension PreviewMemoViewModelTests {
    struct Dependency {
        let testTarget: PreviewMemoViewModel
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
