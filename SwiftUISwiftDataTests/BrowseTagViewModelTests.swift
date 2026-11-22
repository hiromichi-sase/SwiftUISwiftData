//
//  BrowseTagViewModelTests.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import Foundation
import SwiftData
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

    @MainActor
    @Test
    func makeEditTagViewModel_usesProvidedContextAndPreferences() throws {
        let container = try ModelContainer(
            for: Memo.self,
            Tag.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        let tagRepository = TagRepository(modelContext: context)

        let tag = Tag(title: "Original Tag", color: "#FF0000")
        try tagRepository.add(tag)

        let dependency = Dependency(tag: tag)
        defer { dependency.removeUserDefaults() }

        let editViewModel = dependency.testTarget.makeEditTagViewModel(
            modelContext: context
        )

        // 表示中のタグを編集対象として使用する。
        #expect(editViewModel.tag?.id == tag.id)
        #expect(editViewModel.title == "Original Tag")
        #expect(editViewModel.colorString == "#FF0000")

        // BrowseTagViewModel と同じ設定を参照する。
        dependency.userDefaultsRepository.setShowInfo(true)
        #expect(editViewModel.showInfo)

        dependency.userDefaultsRepository.setShowInfo(false)
        #expect(!editViewModel.showInfo)

        // 編集結果が指定したコンテナに保存される。
        editViewModel.title = "Updated Tag"
        editViewModel.colorString = "#00FF00"
        editViewModel.saveTag()

        #expect(editViewModel.currentAlert == nil)
        #expect(editViewModel.toastMessage == "Successfully saved!")

        // 別コンテキストから読み直し、保存結果を確認する。
        let verificationContext = ModelContext(container)
        let savedTags = try verificationContext.fetch(
            FetchDescriptor<Tag>()
        )
        let savedTag = try #require(
            savedTags.first { $0.id == tag.id }
        )

        #expect(savedTag.title == "Updated Tag")
        #expect(savedTag.color == "#00FF00")
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
