//
//  EditMemoViewModelTests.swift
//  EditMemoViewModel
//
//  Created by Hiromichi Sase on 2026/05/04.
//

import SwiftData
import Testing

@testable import SwiftUISwiftData

@MainActor
struct EditMemoViewModelTests {
    // MARK: - Save

    @Test
    func save_newMemo_persistsMemo_andUpdatesState() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let tag = Tag(title: "Tag", color: "#000000", order: 1)
        try dependency.tagRepository.add(tag)

        dependency.sut.title = "Added Title"
        dependency.sut.titleToStore = "Added Title"
        dependency.sut.content = "Added Content"
        dependency.sut.selectedTags = [tag]

        dependency.sut.save()

        let memos = try dependency.memoRepository.memos()
        #expect(memos.count == 1)

        let saved = try #require(memos.first)
        #expect(saved.title == "Added Title")
        #expect(saved.content == "Added Content")
        #expect(saved.tags == [tag])
        #expect(dependency.sut.memo?.id == saved.id)
        #expect(dependency.sut.toastMessage == "Successfully saved!")
        #expect(dependency.sut.currentAlert == nil)
    }

    @Test
    func save_existingMemo_updatesMemo() throws {
        let dependency = try Dependency(existingMemo: true)
        defer { dependency.removeUserDefaults() }

        let updatedTag = Tag(title: "Updated Tag", color: "#111111", order: 1)
        try dependency.tagRepository.add(updatedTag)

        dependency.sut.title = "Updated Title"
        dependency.sut.content = "Updated Content"
        dependency.sut.selectedTags = [updatedTag]

        let before = try #require(dependency.sut.memo)
        let oldCreatedAt = before.createdAt

        dependency.sut.save()

        let memos = try dependency.memoRepository.memos()
        #expect(memos.count == 1)
        let updated = try #require(memos.first)

        #expect(updated.title == "Updated Title")
        #expect(updated.content == "Updated Content")
        #expect(updated.tags == [updatedTag])
        #expect(updated.createdAt == oldCreatedAt)
        #expect(updated.updatedAt >= oldCreatedAt)
        #expect(dependency.sut.toastMessage == "Successfully saved!")
        #expect(dependency.sut.currentAlert == nil)
    }

    // MARK: - Intents

    @Test
    func onTapClose_setsCloseAlert_whenMemoUpdated() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.sut.title = "Changed"
        #expect(dependency.sut.memoUpdated == true)

        dependency.sut.onTapClose()
        #expect(dependency.sut.currentAlert == .close)
    }

    @Test
    func onTapClose_setsNil_whenNotUpdated() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        #expect(dependency.sut.memoUpdated == false)
        dependency.sut.currentAlert = .error

        dependency.sut.onTapClose()
        #expect(dependency.sut.currentAlert == nil)
    }

    @Test
    func rename_submit_and_cancel() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.sut.title = "A"
        dependency.sut.titleToStore = "B"
        dependency.sut.onTapRename()
        #expect(dependency.sut.showTitleView == true)

        dependency.sut.submitRename()
        #expect(dependency.sut.showTitleView == false)
        #expect(dependency.sut.title == "B")

        dependency.sut.titleToStore = "TMP"
        dependency.sut.cancelRename()
        #expect(dependency.sut.showTitleView == false)
        #expect(dependency.sut.titleToStore == dependency.sut.title)
    }

    @Test
    func onTapTag_and_closeAllPresentedViews() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.sut.onTapTag()
        #expect(dependency.sut.showSelectTagView == true)

        dependency.sut.showTitleView = true
        dependency.sut.currentAlert = .error

        dependency.sut.onReceiveCloseAllPresentedViews()
        #expect(dependency.sut.showSelectTagView == false)
        #expect(dependency.sut.showTitleView == false)
        #expect(dependency.sut.currentAlert == nil)
    }

    // MARK: - Derived values

    @Test
    func memoUpdated_newMemo_false_whenEmpty_true_whenChanged() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        #expect(dependency.sut.memoUpdated == false)

        dependency.sut.content = "x"
        #expect(dependency.sut.memoUpdated == true)
    }

    @Test
    func memoUpdated_existingMemo_reflectsDifferences() throws {
        let dependency = try Dependency(existingMemo: true)
        defer { dependency.removeUserDefaults() }

        #expect(dependency.sut.memoUpdated == false)

        dependency.sut.title = "Changed"
        #expect(dependency.sut.memoUpdated == true)
    }

    @Test
    func canSave_dependsOnMemoUpdated_andShowTitleView() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        #expect(dependency.sut.canSave == false)

        dependency.sut.content = "changed"
        #expect(dependency.sut.canSave == true)

        dependency.sut.showTitleView = true
        #expect(dependency.sut.canSave == false)
    }

    @Test
    func canOpenTagSelector_dependsOnShowTitleView_andTagsPresence() throws {
        let dependency = try Dependency(existingTags: 1)
        defer { dependency.removeUserDefaults() }

        #expect(dependency.sut.tags.isEmpty == false)
        #expect(dependency.sut.canOpenTagSelector == true)

        dependency.sut.showTitleView = true
        #expect(dependency.sut.canOpenTagSelector == false)
    }

    @Test
    func navigationTitle_reflectsTitle() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.sut.title = "My Memo"
        #expect(dependency.sut.navigationTitle == "My Memo")
    }

    // MARK: - Preferences

    @Test
    func getContentFontSize() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setContentFontSize(16.0)
        #expect(dependency.sut.getContentFontSize() == 16.0)
    }

    @Test
    func getContentLineSpacing() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setContentLineSpacing(0)
        #expect(dependency.sut.getContentLineSpacing() == 0)
    }

    @Test
    func getShowInfo() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setShowInfo(false)
        #expect(dependency.sut.getShowInfo() == false)
    }
}

extension EditMemoViewModelTests {
    struct Dependency {
        let sut: EditMemoViewModel
        let memoRepository: MemoRepository
        let tagRepository: TagRepository
        let userDefaultsRepository: UserDefaultsRepository

        private let support: TestDependencySupport
        private let container: ModelContainer

        @MainActor
        init(
            existingMemo: Bool = false,
            existingTags: Int = 0
        ) throws {
            let support = TestDependencySupport()
            self.support = support
            self.userDefaultsRepository = support.userDefaultsRepository

            self.container = try ModelContainer(
                for: Memo.self,
                Tag.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )

            self.memoRepository = MemoRepository(modelContext: container.mainContext)
            self.tagRepository = TagRepository(modelContext: container.mainContext)

            if existingTags > 0 {
                for i in 1 ... existingTags {
                    let tag = Tag(title: "Tag \(i)", color: "#000000", order: i)
                    try tagRepository.add(tag)
                }
            }

            let initialMemo: Memo?
            if existingMemo {
                let memo = Memo(title: "Old Title", content: "Old Content", tags: [])
                try memoRepository.add(memo)
                initialMemo = memo
            }
            else {
                initialMemo = nil
            }

            self.sut = EditMemoViewModel(
                memo: initialMemo,
                memoRepository: memoRepository,
                tagRepository: tagRepository,
                userDefaultsRepository: userDefaultsRepository
            )
        }

        func removeUserDefaults() {
            support.removeUserDefaults()
        }
    }
}
