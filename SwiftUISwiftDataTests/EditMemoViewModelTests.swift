//
//  EditMemoViewModelTests.swift
//  EditMemoViewModel
//
//  Created by Hiromichi Sase on 2026/05/04.
//

import Foundation
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

    // MARK: - Save Failure and Retry

    @Test
    func save_newMemo_failureRestoresState_andAllowsRetry() throws {
        struct SimulatedSaveError: Error {}

        let support = TestDependencySupport()
        defer { support.removeUserDefaults() }

        let container = try ModelContainer(
            for: Memo.self,
            Tag.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        context.autosaveEnabled = false

        let tagRepository = TagRepository(modelContext: context)
        let tag = Tag(title: "Tag", color: "#000000")
        try tagRepository.add(tag)

        var shouldFail = true
        let memoRepository = MemoRepository(modelContext: context) { context in
            if shouldFail {
                // willSave 通知後の失敗を模擬する。
                NotificationCenter.default.post(
                    name: ModelContext.willSave,
                    object: context
                )
                throw SimulatedSaveError()
            }

            try context.save()
        }

        let listViewModel = MemosViewModel(
            memoRepository: memoRepository,
            userDefaultsRepository: support.userDefaultsRepository
        )
        let sut = EditMemoViewModel(
            memoRepository: memoRepository,
            tagRepository: tagRepository,
            userDefaultsRepository: support.userDefaultsRepository
        )

        sut.title = "New Memo"
        sut.content = "New Content"
        sut.selectedTags = [tag]
        sut.save()

        // 編集値は残り、再試行できる。
        #expect(sut.currentAlert == .error)
        #expect(sut.memo == nil)
        #expect(sut.title == "New Memo")
        #expect(sut.content == "New Content")
        #expect(sut.selectedTags.map(\.id) == [tag.id])
        #expect(sut.canSave)

        // 未保存のメモやタグとの関連は残らない。
        #expect(listViewModel.memos.isEmpty)
        #expect(try memoRepository.memos().isEmpty)
        #expect(tag.memos.isEmpty)
        #expect(!context.hasChanges)

        let verificationContext = ModelContext(container)
        let savedBeforeRetry = try verificationContext.fetch(
            FetchDescriptor<Memo>()
        )
        #expect(savedBeforeRetry.isEmpty)

        // エラーを閉じ、同じ入力値で再試行する。
        sut.currentAlert = nil
        shouldFail = false
        sut.save()

        #expect(sut.currentAlert == nil)
        #expect(sut.memo != nil)
        #expect(sut.toastMessage == "Successfully saved!")
        #expect(listViewModel.memos.map(\.title) == ["New Memo"])

        let savedMemo = try #require(memoRepository.memos().first)
        #expect(savedMemo.title == "New Memo")
        #expect(savedMemo.content == "New Content")
        #expect(savedMemo.tags.map(\.id) == [tag.id])
    }

    @Test
    func save_existingMemo_failureRestoresModel_andAllowsRetry() throws {
        struct SimulatedSaveError: Error {}

        let support = TestDependencySupport()
        defer { support.removeUserDefaults() }

        let container = try ModelContainer(
            for: Memo.self,
            Tag.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        context.autosaveEnabled = false

        let tagRepository = TagRepository(modelContext: context)
        let originalTag = Tag(title: "Original Tag", color: "#000000")
        let updatedTag = Tag(title: "Updated Tag", color: "#FF0000")
        try tagRepository.add(originalTag)
        try tagRepository.add(updatedTag)

        let setupRepository = MemoRepository(modelContext: context)
        let memo = Memo(title: "Original", content: "Original Content")
        try setupRepository.add(memo, tags: [originalTag])

        let originalUpdatedAt = memo.updatedAt

        var shouldFail = true
        let memoRepository = MemoRepository(modelContext: context) { context in
            if shouldFail {
                NotificationCenter.default.post(
                    name: ModelContext.willSave,
                    object: context
                )
                throw SimulatedSaveError()
            }

            try context.save()
        }

        let listViewModel = MemosViewModel(
            memoRepository: memoRepository,
            userDefaultsRepository: support.userDefaultsRepository
        )
        let sut = EditMemoViewModel(
            memo: memo,
            memoRepository: memoRepository,
            tagRepository: tagRepository,
            userDefaultsRepository: support.userDefaultsRepository
        )

        sut.title = "Updated"
        sut.content = "Updated Content"
        sut.selectedTags = [updatedTag]
        sut.save()

        // 編集値は残り、再試行できる。
        #expect(sut.currentAlert == .error)
        #expect(sut.title == "Updated")
        #expect(sut.content == "Updated Content")
        #expect(sut.selectedTags.map(\.id) == [updatedTag.id])
        #expect(sut.canSave)

        // 一覧・詳細が参照するモデルは保存前の状態に戻る。
        let listedMemo = try #require(listViewModel.memos.first)
        #expect(listedMemo.id == memo.id)
        #expect(listedMemo.title == "Original")
        #expect(listedMemo.content == "Original Content")
        #expect(listedMemo.tags.map(\.id) == [originalTag.id])
        #expect(listedMemo.updatedAt == originalUpdatedAt)
        #expect(!context.hasChanges)

        let verificationContext = ModelContext(container)
        let savedBeforeRetry = try verificationContext.fetch(
            FetchDescriptor<Memo>()
        )
        let originalSavedMemo = try #require(savedBeforeRetry.first)

        #expect(originalSavedMemo.title == "Original")
        #expect(originalSavedMemo.content == "Original Content")
        #expect(originalSavedMemo.tags.map(\.id) == [originalTag.id])

        // 同じ入力値で再試行する。
        sut.currentAlert = nil
        shouldFail = false
        sut.save()

        #expect(sut.currentAlert == nil)
        #expect(sut.toastMessage == "Successfully saved!")
        #expect(listViewModel.memos.first?.title == "Updated")

        let updatedMemo = try #require(memoRepository.memos().first)
        #expect(updatedMemo.title == "Updated")
        #expect(updatedMemo.content == "Updated Content")
        #expect(updatedMemo.tags.map(\.id) == [updatedTag.id])
    }

    @Test
    func save_withPendingChanges_preservesChanges_andAllowsRetry() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let context = dependency.memoRepository.modelContext
        context.autosaveEnabled = false

        // 同じコンテキストに別の未保存変更を用意する。
        let pendingTag = Tag(title: "Pending Tag", color: "#000000")
        context.insert(pendingTag)
        #expect(context.hasChanges)

        dependency.sut.title = "New Memo"
        dependency.sut.content = "New Content"
        dependency.sut.save()

        #expect(dependency.sut.currentAlert == .error)
        #expect(dependency.sut.error != nil)
        #expect(dependency.sut.memo == nil)
        #expect(dependency.sut.title == "New Memo")
        #expect(dependency.sut.content == "New Content")
        #expect(dependency.sut.canSave)

        // 既存の未保存変更は取り消されない。
        #expect(context.hasChanges)
        let pendingTags = try context.fetch(FetchDescriptor<Tag>())
        #expect(pendingTags.map(\.id).contains(pendingTag.id))
        #expect(try dependency.memoRepository.memos().isEmpty)

        // 別の変更を保存した後、再試行する。
        try context.save()
        #expect(!context.hasChanges)

        dependency.sut.currentAlert = nil
        dependency.sut.save()

        #expect(dependency.sut.currentAlert == nil)
        #expect(dependency.sut.memo != nil)
        #expect(try dependency.memoRepository.memos().map(\.title) == ["New Memo"])

        let tags = try context.fetch(FetchDescriptor<Tag>())
        #expect(tags.map(\.id).contains(pendingTag.id))
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

    // MARK: - Derived Values

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

            self.memoRepository = MemoRepository(
                modelContext: container.mainContext
            )
            self.tagRepository = TagRepository(
                modelContext: container.mainContext
            )

            if existingTags > 0 {
                for i in 1 ... existingTags {
                    let tag = Tag(
                        title: "Tag \(i)",
                        color: "#000000",
                        order: i
                    )
                    try tagRepository.add(tag)
                }
            }

            let initialMemo: Memo?
            if existingMemo {
                let memo = Memo(
                    title: "Old Title",
                    content: "Old Content",
                    tags: []
                )
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
