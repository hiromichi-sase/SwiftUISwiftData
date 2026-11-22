//
//  MemosViewModelTests.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/04.
//

import SwiftData
import SwiftUI
import Testing

@testable import SwiftUISwiftData

struct MemosViewModelTests {
    @MainActor
    @Test
    func filteredMemos() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let tag1 = Tag(title: "Test Tag 1", color: "#000000")
        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            tags: [tag1],
            memos: [
                Memo(title: "Test Title 1", content: "Test Memo 1", order: 1, tags: [tag1]),
                Memo(title: "Test Title 2", content: "Test Memo 2", order: 2, tags: [tag1]),
            ]
        )

        let testTarget = dependency.testTarget
        let filtered = testTarget.filteredMemos(by: "Title 1", and: [tag1])
        #expect(filtered.count == 2)
    }

    @MainActor
    @Test
    func filteredMemos_noFilter() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let tag1 = Tag(title: "Test Tag 1", color: "#000000")
        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            tags: [tag1],
            memos: [
                Memo(title: "Test Title 1", content: "Test Memo 1", order: 1, tags: [tag1]),
                Memo(title: "Test Title 2", content: "Test Memo 2", order: 2, tags: [tag1]),
            ]
        )

        let testTarget = dependency.testTarget
        let filtered = testTarget.filteredMemos(by: "", and: [])
        #expect(filtered.count == 2)
    }

    @MainActor
    @Test
    func duplicate() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let memo1 = Memo(title: "Test Title 1", content: "Test Memo 1", order: 1)
        let memo2 = Memo(title: "Test Title 2", content: "Test Memo 2", order: 2)
        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            memos: [memo1, memo2]
        )

        let testTarget = dependency.testTarget
        let countBeforeDuplication = try dependency.memoRepository.memos().count
        try testTarget.duplicate(memo1)

        let memos = try dependency.memoRepository.memos()
        #expect(memos.count == countBeforeDuplication + 1)
        #expect(memos[0].title == memo1.title)
        #expect(memos[1].title == memos[0].title)
        #expect(memos[2].title == memo2.title)
    }

    @MainActor
    @Test
    func deleteMemos() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let memo1 = Memo(title: "Test Title 1", content: "Test Memo 1", order: 1)
        let memo2 = Memo(title: "Test Title 2", content: "Test Memo 2", order: 2)
        let memo3 = Memo(title: "Test Title 3", content: "Test Memo 3", order: 3)
        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            memos: [memo1, memo2, memo3]
        )

        let testTarget = dependency.testTarget
        try testTarget.delete([memo2])

        let memos = try dependency.memoRepository.memos()
        #expect(memos.count == 2)
        #expect(memos[0].order == 1)
        #expect(memos[1].order == 2)
    }

    @MainActor
    @Test
    func moveMemo() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let memo1 = Memo(title: "Test Title 1", content: "Test Memo 1", order: 1)
        let memo2 = Memo(title: "Test Title 2", content: "Test Memo 2", order: 2)
        let memo3 = Memo(title: "Test Title 3", content: "Test Memo 3", order: 3)
        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            memos: [memo1, memo2, memo3]
        )

        let testTarget = dependency.testTarget
        try testTarget.moveMemo(from: [2], to: 1)

        let memos = try dependency.memoRepository.memos()
        #expect(memos.count == 3)
        #expect(memos[0].title == "Test Title 1")
        #expect(memos[1].title == "Test Title 3")
        #expect(memos[2].title == "Test Title 2")
    }

    @MainActor
    @Test
    func moveMemo_invalidSource_throws() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "A", content: "A", order: 1),
                Memo(title: "B", content: "B", order: 2),
            ]
        )

        let testTarget = dependency.testTarget

        #expect(throws: MemosViewModel.MoveMemoValidationError.invalidSource) {
            try testTarget.moveMemo(from: [999], to: 1)
        }
    }

    @MainActor
    @Test
    func moveMemo_invalidDestination_throws() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "A", content: "A", order: 1),
                Memo(title: "B", content: "B", order: 2),
            ]
        )

        let testTarget = dependency.testTarget

        #expect(throws: MemosViewModel.MoveMemoValidationError.invalidDestination) {
            try testTarget.moveMemo(from: [0], to: 999)
        }
    }

    @MainActor
    @Test
    func protectMemos() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "Test Title 1", content: "Test Memo 1", protected: false),
                Memo(title: "Test Title 2", content: "Test Memo 2", protected: false),
                Memo(title: "Test Title 3", content: "Test Memo 3", protected: false),
            ]
        )

        let testTarget = dependency.testTarget
        let memosBefore = try dependency.memoRepository.memos()
        try testTarget.protect([memosBefore[0], memosBefore[1], memosBefore[2]])

        let memos = try dependency.memoRepository.memos()
        for memo in memos {
            #expect(memo.protected)
        }
    }

    @MainActor
    @Test
    func unprotectMemos() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "Test Title 1", content: "Test Memo 1", protected: true),
                Memo(title: "Test Title 2", content: "Test Memo 2", protected: true),
                Memo(title: "Test Title 3", content: "Test Memo 3", protected: true),
            ]
        )

        let testTarget = dependency.testTarget
        let memosBefore = try dependency.memoRepository.memos()
        try testTarget.unprotect([memosBefore[0], memosBefore[1], memosBefore[2]])

        let memos = try dependency.memoRepository.memos()
        for memo in memos {
            #expect(!memo.protected)
        }
    }

    @MainActor
    @Test
    func displayedMemos_active_returnsAllMemos() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "Apple", content: "A", order: 1),
                Memo(title: "Banana", content: "B", order: 2),
            ]
        )

        let testTarget = dependency.testTarget
        _ = testTarget.filteredMemos(by: "Apple", and: [])

        let displayed = testTarget.displayedMemos(editMode: .active)
        #expect(displayed.count == 2)
    }

    @MainActor
    @Test
    func displayedMemos_inactive_returnsFilteredMemos() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "Apple", content: "A", order: 1),
                Memo(title: "Banana", content: "B", order: 2),
            ]
        )

        let testTarget = dependency.testTarget
        _ = testTarget.filteredMemos(by: "Apple", and: [])

        let displayed = testTarget.displayedMemos(editMode: .inactive)
        #expect(displayed.count == 1)
        #expect(displayed[0].title == "Apple")
    }

    @MainActor
    @Test
    func navigationTitle_active_returnsSelectionCount() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "A", content: "A", order: 1),
                Memo(title: "B", content: "B", order: 2),
            ]
        )

        let testTarget = dependency.testTarget
        testTarget.selectAll()
        let title = testTarget.navigationTitle(editMode: .active)

        #expect(title == "Memos (2/2)")
    }

    @MainActor
    @Test
    func navigationTitle_inactive_filtering_returnsFilteredCount() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "Apple", content: "A", order: 1),
                Memo(title: "Banana", content: "B", order: 2),
            ]
        )

        let testTarget = dependency.testTarget
        _ = testTarget.filteredMemos(by: "Apple", and: [])

        let title = testTarget.navigationTitle(editMode: .inactive)
        #expect(title == "Memos (1/2)")
    }

    @MainActor
    @Test
    func navigationTitle_inactive_noFilter_returnsTotalCount() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "A", content: "A", order: 1),
                Memo(title: "B", content: "B", order: 2),
            ]
        )

        let testTarget = dependency.testTarget
        let title = testTarget.navigationTitle(editMode: .inactive)

        #expect(title == "Memos (2)")
    }

    @MainActor
    @Test
    func toggleSelection_togglesMembership() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let testTarget = dependency.testTarget
        let id = UUID()

        testTarget.toggleSelection(for: id)
        #expect(testTarget.selection.contains(id))

        testTarget.toggleSelection(for: id)
        #expect(!testTarget.selection.contains(id))
    }

    @MainActor
    @Test
    func selectAllAndDeselectAll_workAsExpected() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "A", content: "A", order: 1),
                Memo(title: "B", content: "B", order: 2),
            ]
        )

        let testTarget = dependency.testTarget
        testTarget.selectAll()
        #expect(testTarget.selection.count == 2)

        testTarget.deselectAll()
        #expect(testTarget.selection.isEmpty)
    }

    @MainActor
    @Test
    func selectedMemos_returnsSelectedOnly() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let memo1 = Memo(title: "A", content: "A", order: 1)
        let memo2 = Memo(title: "B", content: "B", order: 2)
        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            memos: [memo1, memo2]
        )

        let testTarget = dependency.testTarget
        testTarget.selection = [memo2.id]

        let selected = testTarget.selectedMemos()
        #expect(selected.count == 1)
        #expect(selected[0].id == memo2.id)
    }

    @MainActor
    @Test
    func clearFilter_resetsFilteringState() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let tag = Tag(title: "Tag", color: "#000000")
        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            tags: [tag],
            memos: [
                Memo(title: "Apple", content: "A", order: 1, tags: [tag]),
                Memo(title: "Banana", content: "B", order: 2),
            ]
        )

        let testTarget = dependency.testTarget
        _ = testTarget.filteredMemos(by: "Apple", and: [tag])
        #expect(testTarget.isFiltering)

        testTarget.clearFilter()

        #expect(!testTarget.isFiltering)
        #expect(testTarget.filterQuery == "")
        #expect(testTarget.filterTags.isEmpty)
        #expect(testTarget.keywordsForFiltering.isEmpty)
        #expect(testTarget.filteredMemos.count == testTarget.memos.count)
    }

    @MainActor
    @Test
    func handleMemosChanged_active_emptyNewMemos_clearsSelection() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let testTarget = dependency.testTarget
        testTarget.selection = [UUID()]

        testTarget.handleMemosChanged(
            oldMemos: [Memo(title: "A", content: "A")],
            newMemos: [],
            editMode: .active
        )

        #expect(testTarget.selection.isEmpty)
    }

    @MainActor
    @Test
    func handleMemosChanged_inactive_newMemo_selectsNewMemo() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let testTarget = dependency.testTarget
        let oldMemo = Memo(title: "Old", content: "Old", order: 1)
        let newMemo = Memo(title: "New", content: "New", order: 2)

        testTarget.handleMemosChanged(
            oldMemos: [oldMemo],
            newMemos: [oldMemo, newMemo],
            editMode: .inactive
        )

        #expect(testTarget.selectedMemo?.id == newMemo.id)
        #expect(testTarget.selection.isEmpty)
    }

    @MainActor
    @Test
    func handleMemosChanged_inactive_emptyNewMemos_clearsSelectedMemoAndFilter() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            memos: [Memo(title: "A", content: "A", order: 1)]
        )

        let testTarget = dependency.testTarget
        testTarget.selectedMemo = Memo(title: "X", content: "X")
        _ = testTarget.filteredMemos(by: "A", and: [])

        testTarget.handleMemosChanged(
            oldMemos: [Memo(title: "A", content: "A", order: 1)],
            newMemos: [],
            editMode: .inactive
        )

        #expect(testTarget.selectedMemo == nil)
        #expect(testTarget.filterQuery == "")
        #expect(!testTarget.isFiltering)
    }

    @MainActor
    @Test
    func onDuplicateMemo_success_returnsToast() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let memo = Memo(title: "A", content: "A", order: 1)
        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            memos: [memo]
        )

        let result = dependency.testTarget.onDuplicateMemo(memo)
        #expect(result == .toast("Successfully duplicated!"))
    }

    @MainActor
    @Test
    func onDeleteMemos_selectedDeleted_returnsNilAndToast() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let memo1 = Memo(title: "A", content: "A", order: 1)
        let memo2 = Memo(title: "B", content: "B", order: 2)
        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            memos: [memo1, memo2]
        )

        let output = dependency.testTarget.onDeleteMemos([memo1], currentSelectedMemo: memo1)

        #expect(output.newSelectedMemo == nil)
        #expect(output.result == .toast("Successfully deleted!"))
    }

    @MainActor
    @Test
    func onDeleteMemos_selectedNotDeleted_keepsSelectionAndToast() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let memo1 = Memo(title: "A", content: "A", order: 1)
        let memo2 = Memo(title: "B", content: "B", order: 2)
        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            memos: [memo1, memo2]
        )

        let output = dependency.testTarget.onDeleteMemos([memo2], currentSelectedMemo: memo1)

        #expect(output.newSelectedMemo?.id == memo1.id)
        #expect(output.result == .toast("Successfully deleted!"))
    }

    @MainActor
    @Test
    func onMoveMemo_success_returnsNone() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "A", content: "A", order: 1),
                Memo(title: "B", content: "B", order: 2),
                Memo(title: "C", content: "C", order: 3),
            ]
        )

        let result = dependency.testTarget.onMoveMemo(from: IndexSet(integer: 2), to: 1)
        #expect(result == .none)
    }

    @MainActor
    @Test
    func onMoveMemo_invalidSource_returnsAlert() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "A", content: "A", order: 1),
                Memo(title: "B", content: "B", order: 2),
            ]
        )

        let result = dependency.testTarget.onMoveMemo(from: IndexSet(integer: 999), to: 1)
        if case .alert(.error, _) = result {
            #expect(Bool(true))
        }
        else {
            #expect(Bool(false))
        }
    }

    @MainActor
    @Test
    func onProtectMemos_authSuccess_returnsNoneAndProtects() async throws {
        let dependency = try Dependency(authenticateHandler: { true })
        defer { dependency.removeUserDefaults() }

        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "A", content: "A", protected: false),
                Memo(title: "B", content: "B", protected: false),
            ]
        )

        let memosBefore = try dependency.memoRepository.memos()
        let result = await dependency.testTarget.onProtectMemos(memosBefore)

        #expect(result == .none)

        let memosAfter = try dependency.memoRepository.memos()
        for memo in memosAfter {
            #expect(memo.protected)
        }
    }

    @MainActor
    @Test
    func onProtectMemos_authFailure_returnsAlert() async throws {
        enum DummyError: Error { case failed }

        let dependency = try Dependency(authenticateHandler: { throw DummyError.failed })
        defer { dependency.removeUserDefaults() }

        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            memos: [Memo(title: "A", content: "A", protected: false)]
        )

        let memosBefore = try dependency.memoRepository.memos()
        let result = await dependency.testTarget.onProtectMemos(memosBefore)

        if case .alert(.error, _) = result {
            #expect(Bool(true))
        }
        else {
            #expect(Bool(false))
        }
    }

    @MainActor
    @Test
    func onUnprotectMemos_authSuccess_returnsNoneAndUnprotects() async throws {
        let dependency = try Dependency(authenticateHandler: { true })
        defer { dependency.removeUserDefaults() }

        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "A", content: "A", protected: true),
                Memo(title: "B", content: "B", protected: true),
            ]
        )

        let memosBefore = try dependency.memoRepository.memos()
        let result = await dependency.testTarget.onUnprotectMemos(memosBefore)

        #expect(result == .none)

        let memosAfter = try dependency.memoRepository.memos()
        for memo in memosAfter {
            #expect(!memo.protected)
        }
    }

    @MainActor
    @Test
    func onUnprotectMemos_authFailure_returnsAlert() async throws {
        enum DummyError: Error { case failed }

        let dependency = try Dependency(authenticateHandler: { throw DummyError.failed })
        defer { dependency.removeUserDefaults() }

        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            memos: [Memo(title: "A", content: "A", protected: true)]
        )

        let memosBefore = try dependency.memoRepository.memos()
        let result = await dependency.testTarget.onUnprotectMemos(memosBefore)

        if case .alert(.error, _) = result {
            #expect(Bool(true))
        }
        else {
            #expect(Bool(false))
        }
    }

    @MainActor
    @Test
    func getTitleLineLimit() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setTitleLineLimit(3)
        let testTarget = dependency.testTarget
        #expect(testTarget.getTitleLineLimit() == 3)
    }

    @MainActor
    @Test
    func getTitleFontSize() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setTitleFontSize(16.0)
        let testTarget = dependency.testTarget
        #expect(testTarget.getTitleFontSize() == 16.0)
    }

    @MainActor
    @Test
    func getTitleLineSpacing() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setTitleLineSpacing(.zero)
        let testTarget = dependency.testTarget
        #expect(testTarget.getTitleLineSpacing() == .zero)
    }

    @MainActor
    @Test
    func getShowInfo() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setShowInfo(false)
        let testTarget = dependency.testTarget
        #expect(!testTarget.getShowInfo())
    }

    @MainActor
    @Test
    func onDeleteMemos_selectedDeleted_returnsNilSelectionAndToast() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let memo1 = Memo(title: "A", content: "A", order: 1)
        let memo2 = Memo(title: "B", content: "B", order: 2)
        try seed(
            memoRepository: dependency.memoRepository,
            context: dependency.memoRepository.modelContext,
            memos: [memo1, memo2]
        )

        let output = dependency.testTarget.onDeleteMemos([memo1], currentSelectedMemo: memo1)

        #expect(output.newSelectedMemo == nil)
        #expect(output.result == .toast("Successfully deleted!"))
    }

    @MainActor
    @Test
    func makeEditMemoViewModel_usesInjectedDependencies() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let tagRepository = TagRepository(
            modelContext: dependency.memoRepository.modelContext
        )
        let tag = Tag(title: "Test Tag", color: "#FF0000")
        try tagRepository.add(tag)

        let editViewModel = dependency.testTarget.makeEditMemoViewModel()

        // タグはメモ一覧と同じ ModelContext から取得される。
        #expect(editViewModel.tags.map(\.id) == [tag.id])
        #expect(editViewModel.memo == nil)

        // 生成後の設定変更も参照できる。
        dependency.userDefaultsRepository.setContentFontSize(24.0)
        #expect(editViewModel.getContentFontSize() == 24.0)

        // 新規メモがテスト用 Repository に保存される。
        editViewModel.title = "New Memo"
        editViewModel.content = "Test Content"
        editViewModel.selectedTags = [tag]
        editViewModel.save()

        let savedMemos = try dependency.memoRepository.memos()
        let savedMemo = try #require(savedMemos.first)

        #expect(savedMemos.count == 1)
        #expect(savedMemo.title == "New Memo")
        #expect(savedMemo.content == "Test Content")
        #expect(savedMemo.tags.map(\.id) == [tag.id])
        #expect(editViewModel.memo?.id == savedMemo.id)
        #expect(editViewModel.error == nil)
    }

    @MainActor
    @Test
    func makeFilterMemosViewModel_usesInjectedDependencies() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let tagRepository = TagRepository(
            modelContext: dependency.memoRepository.modelContext
        )
        let tag = Tag(title: "Filter Tag", color: "#00FF00")
        try tagRepository.add(tag)

        let filterViewModel = dependency.testTarget.makeFilterMemosViewModel()

        #expect(filterViewModel.tags.map(\.id) == [tag.id])

        dependency.userDefaultsRepository.setTitleLineLimit(4)
        dependency.userDefaultsRepository.setTitleFontSize(24.0)
        dependency.userDefaultsRepository.setTitleLineSpacing(2.0)

        #expect(filterViewModel.titleLineLimit == 4)
        #expect(filterViewModel.titleFontSize == 24.0)
        #expect(filterViewModel.titleLineSpacing == 2.0)

        // フィルター画面から開くタグ選択画面にも依存関係が渡る。
        let selectViewModel = filterViewModel.makeSelectTagViewModel()

        #expect(selectViewModel.tags.map(\.id) == [tag.id])
        #expect(selectViewModel.titleLineLimit == 4)
        #expect(selectViewModel.titleFontSize == 24.0)
        #expect(selectViewModel.titleLineSpacing == 2.0)
    }

    @MainActor
    @Test
    func makePreviewMemoViewModel_usesProvidedMemoAndPreferences() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let memo = Memo(title: "Test Memo", content: "Preview Content")
        let previewViewModel = dependency.testTarget.makePreviewMemoViewModel(
            memo: memo
        )

        #expect(previewViewModel.displayContent == "Preview Content")
        #expect(!previewViewModel.isContentEmpty)

        dependency.userDefaultsRepository.setContentFontSize(24.0)
        dependency.userDefaultsRepository.setContentLineSpacing(2.0)

        #expect(previewViewModel.contentFontSize == 24.0)
        #expect(previewViewModel.contentLineSpacing == 2.0)

        // 渡したメモの変更が表示内容に反映される。
        memo.content = "Updated Content"
        #expect(previewViewModel.displayContent == "Updated Content")
    }

    @MainActor
    private func seed(
        memoRepository: MemoRepository,
        context: ModelContext,
        tags: [Tag] = [],
        memos: [Memo]
    ) throws {
        for tag in tags {
            context.insert(tag)
        }
        for memo in memos {
            try memoRepository.add(memo)
        }
    }
}

extension MemosViewModelTests {
    struct Dependency {
        private let container: ModelContainer
        let testTarget: MemosViewModel
        let memoRepository: MemoRepository
        let userDefaultsRepository: UserDefaultsRepository
        private let support: TestDependencySupport

        @MainActor
        init(
            authenticateHandler: @escaping MemosViewModel.AuthenticateHandler = { true }
        ) throws {
            let support = TestDependencySupport()
            self.support = support
            userDefaultsRepository = support.userDefaultsRepository

            container = try ModelContainer(
                for: Memo.self,
                Tag.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )

            memoRepository = MemoRepository(modelContext: container.mainContext)

            testTarget = .init(
                memoRepository: memoRepository,
                userDefaultsRepository: userDefaultsRepository,
                authenticateHandler: authenticateHandler
            )
        }

        func removeUserDefaults() {
            support.removeUserDefaults()
        }
    }
}
