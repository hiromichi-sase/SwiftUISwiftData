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

@MainActor
struct MemosViewModelTests {
    // MARK: - Filtering

    @Test
    func filteredMemos() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let tag = Tag(title: "Test Tag 1", color: "#000000")
        try seed(
            context: dependency.memoRepository.modelContext,
            tags: [tag],
            memos: [
                Memo(title: "Test Title 1", content: "Test Memo 1", tags: [tag]),
                Memo(title: "Test Title 2", content: "Test Memo 2", tags: [tag]),
            ]
        )

        let filtered = dependency.testTarget.filteredMemos(
            by: "Title 1",
            and: [tag]
        )

        #expect(filtered.count == 2)
    }

    @Test
    func filteredMemos_noFilter() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let tag = Tag(title: "Test Tag 1", color: "#000000")
        try seed(
            context: dependency.memoRepository.modelContext,
            tags: [tag],
            memos: [
                Memo(title: "Test Title 1", content: "Test Memo 1", tags: [tag]),
                Memo(title: "Test Title 2", content: "Test Memo 2", tags: [tag]),
            ]
        )

        let filtered = dependency.testTarget.filteredMemos(by: "", and: [])
        #expect(filtered.count == 2)
    }

    @Test
    func clearFilter_resetsFilteringState() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let tag = Tag(title: "Tag", color: "#000000")
        try seed(
            context: dependency.memoRepository.modelContext,
            tags: [tag],
            memos: [
                Memo(title: "Apple", content: "A", tags: [tag]),
                Memo(title: "Banana", content: "B"),
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

    // MARK: - Repository Operations

    @Test
    func duplicate() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let memo1 = Memo(title: "Test Title 1", content: "Test Memo 1")
        let memo2 = Memo(title: "Test Title 2", content: "Test Memo 2")
        try seed(
            context: dependency.memoRepository.modelContext,
            memos: [memo1, memo2]
        )

        let countBefore = try dependency.memoRepository.memos().count
        try dependency.testTarget.duplicate(memo1)

        let memos = try dependency.memoRepository.memos()
        #expect(memos.count == countBefore + 1)
        #expect(memos[0].title == memo1.title)
        #expect(memos[1].title == memos[0].title)
        #expect(memos[2].title == memo2.title)
    }

    @Test
    func deleteMemos() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let memo1 = Memo(title: "A", content: "A")
        let memo2 = Memo(title: "B", content: "B")
        let memo3 = Memo(title: "C", content: "C")
        try seed(
            context: dependency.memoRepository.modelContext,
            memos: [memo1, memo2, memo3]
        )

        try dependency.testTarget.delete([memo2])

        let memos = try dependency.memoRepository.memos()
        #expect(memos.count == 2)
        #expect(memos.map(\.title) == ["A", "C"])
        #expect(memos.map(\.order) == [1, 2])
    }

    @Test
    func deleteFailure_restoresMemosAndSelection_allowsRetry() throws {
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

        // 初期データは通常の Repository で保存する。
        let setupRepository = MemoRepository(modelContext: context)
        let memoA = Memo(title: "A", content: "A")
        let memoB = Memo(title: "B", content: "B")
        try setupRepository.add(memoA)
        try setupRepository.add(memoB)

        var shouldFail = true

        // テスト対象には保存処理を差し替えた Repository を渡す。
        let repository = MemoRepository(modelContext: context) { context in
            if shouldFail {
                NotificationCenter.default.post(
                    name: ModelContext.willSave,
                    object: context
                )
                throw SimulatedSaveError()
            }

            try context.save()
        }

        let viewModel = MemosViewModel(
            memoRepository: repository,
            userDefaultsRepository: support.userDefaultsRepository
        )
        viewModel.selection = [memoA.id]

        let failed = viewModel.onDeleteMemos(
            [memoA],
            currentSelectedMemo: memoA
        )

        if case .alert(.error, _) = failed.result {
            // 期待どおりエラー。
        }
        else {
            Issue.record("削除失敗時にエラーが返されませんでした")
        }

        #expect(failed.newSelectedMemo?.id == memoA.id)
        #expect(viewModel.selection == [memoA.id])
        #expect(viewModel.memos.map(\.title) == ["A", "B"])
        #expect(viewModel.memos.map(\.order) == [1, 2])
        #expect(try repository.memos().map(\.title) == ["A", "B"])
        #expect(!context.hasChanges)

        // 保存処理を正常に戻して再試行する。
        shouldFail = false

        let retried = viewModel.onDeleteMemos(
            [memoA],
            currentSelectedMemo: memoA
        )

        #expect(retried.result == .toast("Successfully deleted!"))
        #expect(retried.newSelectedMemo == nil)
        #expect(viewModel.selection.isEmpty)
        #expect(viewModel.memos.map(\.title) == ["B"])
    }

    @Test
    func moveMemo() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        try seed(
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "A", content: "A"),
                Memo(title: "B", content: "B"),
                Memo(title: "C", content: "C"),
            ]
        )

        try dependency.testTarget.moveMemo(from: [2], to: 1)

        let memos = try dependency.memoRepository.memos()
        #expect(memos.map(\.title) == ["A", "C", "B"])
        #expect(memos.map(\.order) == [1, 2, 3])
    }

    @Test
    func moveMemo_invalidSource_throws() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        try seed(
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "A", content: "A"),
                Memo(title: "B", content: "B"),
            ]
        )

        #expect(throws: MemosViewModel.MoveMemoValidationError.invalidSource) {
            try dependency.testTarget.moveMemo(from: [999], to: 1)
        }
    }

    @Test
    func moveMemo_invalidDestination_throws() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        try seed(
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "A", content: "A"),
                Memo(title: "B", content: "B"),
            ]
        )

        #expect(throws: MemosViewModel.MoveMemoValidationError.invalidDestination) {
            try dependency.testTarget.moveMemo(from: [0], to: 999)
        }
    }

    @Test
    func protectMemos() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        try seed(
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "A", content: "A", protected: false),
                Memo(title: "B", content: "B", protected: false),
                Memo(title: "C", content: "C", protected: false),
            ]
        )

        let memos = try dependency.memoRepository.memos()
        try dependency.testTarget.protect(memos)

        #expect(try dependency.memoRepository.memos().allSatisfy(\.protected))
    }

    @Test
    func unprotectMemos() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        try seed(
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "A", content: "A", protected: true),
                Memo(title: "B", content: "B", protected: true),
                Memo(title: "C", content: "C", protected: true),
            ]
        )

        let memos = try dependency.memoRepository.memos()
        try dependency.testTarget.unprotect(memos)

        #expect(try dependency.memoRepository.memos().allSatisfy { !$0.protected })
    }

    @Test
    func duplicateFailure_restoresMemosAndOrder_allowsRetry() throws {
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
        let setupRepository = MemoRepository(modelContext: context)

        let tag = Tag(title: "Tag", color: "#000000")
        try tagRepository.add(tag)

        let memoA = Memo(title: "A", content: "A")
        let memoB = Memo(title: "B", content: "B")
        try setupRepository.add(memoA, tags: [tag])
        try setupRepository.add(memoB)

        var shouldFail = true
        let repository = MemoRepository(modelContext: context) { context in
            if shouldFail {
                NotificationCenter.default.post(
                    name: ModelContext.willSave,
                    object: context
                )
                throw SimulatedSaveError()
            }

            try context.save()
        }

        let viewModel = MemosViewModel(
            memoRepository: repository,
            userDefaultsRepository: support.userDefaultsRepository
        )
        viewModel.selectedMemo = memoA
        viewModel.selection = [memoA.id]

        let failed = viewModel.onDuplicateMemo(memoA)

        if case .alert(.error, _) = failed {
            // 期待どおりエラー。
        }
        else {
            Issue.record("複製失敗時にエラーが返されませんでした")
        }

        #expect(viewModel.selectedMemo?.id == memoA.id)
        #expect(viewModel.selection == [memoA.id])
        #expect(viewModel.memos.map(\.id) == [memoA.id, memoB.id])
        #expect(viewModel.memos.map(\.order) == [1, 2])
        #expect(try repository.memos().map(\.id) == [memoA.id, memoB.id])
        #expect(tag.memos.map(\.id) == [memoA.id])
        #expect(!context.hasChanges)

        // 別コンテキストからも複製が保存されていないことを確認する。
        let verificationContext = ModelContext(container)
        let savedBeforeRetry = try verificationContext.fetch(
            FetchDescriptor<Memo>()
        )
        #expect(savedBeforeRetry.count == 2)

        // 再試行すると、タグ付きメモが複製される。
        shouldFail = false
        let retried = viewModel.onDuplicateMemo(memoA)

        #expect(retried == .toast("Successfully duplicated!"))

        let memos = try repository.memos()
        #expect(memos.count == 3)
        #expect(memos.map(\.title) == ["A", "A", "B"])
        #expect(memos.map(\.order) == [1, 2, 3])
        #expect(memos[1].id != memoA.id)
        #expect(memos[1].tags.map(\.id) == [tag.id])
    }

    @Test
    func moveFailure_restoresOrderAndSelection_allowsRetry() throws {
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

        let setupRepository = MemoRepository(modelContext: context)
        let memoA = Memo(title: "A", content: "A")
        let memoB = Memo(title: "B", content: "B")
        let memoC = Memo(title: "C", content: "C")
        try setupRepository.add(memoA)
        try setupRepository.add(memoB)
        try setupRepository.add(memoC)

        var shouldFail = true
        let repository = MemoRepository(modelContext: context) { context in
            if shouldFail {
                NotificationCenter.default.post(
                    name: ModelContext.willSave,
                    object: context
                )
                throw SimulatedSaveError()
            }

            try context.save()
        }

        let viewModel = MemosViewModel(
            memoRepository: repository,
            userDefaultsRepository: support.userDefaultsRepository
        )
        viewModel.selection = [memoB.id]

        let failed = viewModel.onMoveMemo(
            from: IndexSet(integer: 2),
            to: 1
        )

        if case .alert(.error, _) = failed {
            // 期待どおりエラー。
        }
        else {
            Issue.record("並べ替え失敗時にエラーが返されませんでした")
        }

        #expect(viewModel.selection == [memoB.id])
        #expect(viewModel.memos.map(\.title) == ["A", "B", "C"])
        #expect(viewModel.memos.map(\.order) == [1, 2, 3])
        #expect(try repository.memos().map(\.title) == ["A", "B", "C"])
        #expect(!context.hasChanges)

        let verificationContext = ModelContext(container)
        let descriptor = FetchDescriptor<Memo>(
            sortBy: [SortDescriptor(\.order)]
        )
        let savedBeforeRetry = try verificationContext.fetch(descriptor)
        #expect(savedBeforeRetry.map(\.title) == ["A", "B", "C"])

        shouldFail = false
        let retried = viewModel.onMoveMemo(
            from: IndexSet(integer: 2),
            to: 1
        )

        #expect(retried == .none)
        #expect(viewModel.selection == [memoB.id])
        #expect(viewModel.memos.map(\.title) == ["A", "C", "B"])
        #expect(viewModel.memos.map(\.order) == [1, 2, 3])
    }

    @Test(arguments: [false, true])
    func protectionFailure_restoresState_allowsRetry(
        initiallyProtected: Bool
    ) async throws {
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

        let setupRepository = MemoRepository(modelContext: context)
        let memo = Memo(
            title: "Memo",
            content: "Content",
            protected: initiallyProtected
        )
        try setupRepository.add(memo)

        var shouldFail = true
        let repository = MemoRepository(modelContext: context) { context in
            if shouldFail {
                NotificationCenter.default.post(
                    name: ModelContext.willSave,
                    object: context
                )
                throw SimulatedSaveError()
            }

            try context.save()
        }

        let viewModel = MemosViewModel(
            memoRepository: repository,
            userDefaultsRepository: support.userDefaultsRepository,
            authenticateHandler: { true }
        )
        viewModel.selection = [memo.id]

        let failed: MemosViewModel.ActionResult
        if initiallyProtected {
            failed = await viewModel.onUnprotectMemos([memo])
        }
        else {
            failed = await viewModel.onProtectMemos([memo])
        }

        if case .alert(.error, _) = failed {
            // 期待どおりエラー。
        }
        else {
            Issue.record("保護状態の保存失敗時にエラーが返されませんでした")
        }

        #expect(memo.protected == initiallyProtected)
        #expect(viewModel.memos.first?.protected == initiallyProtected)
        #expect(viewModel.selection == [memo.id])
        #expect(!context.hasChanges)

        let verificationContext = ModelContext(container)
        let savedBeforeRetry = try verificationContext.fetch(
            FetchDescriptor<Memo>()
        )
        let savedMemo = try #require(savedBeforeRetry.first)
        #expect(savedMemo.protected == initiallyProtected)

        shouldFail = false

        let retried: MemosViewModel.ActionResult
        if initiallyProtected {
            retried = await viewModel.onUnprotectMemos([memo])
        }
        else {
            retried = await viewModel.onProtectMemos([memo])
        }

        #expect(retried == .none)
        #expect(memo.protected == !initiallyProtected)
        #expect(viewModel.memos.first?.protected == !initiallyProtected)
        #expect(viewModel.selection == [memo.id])
    }

    // MARK: - Displayed Memos

    @Test
    func displayedMemos_active_returnsAllMemos() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        try seed(
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "Apple", content: "A"),
                Memo(title: "Banana", content: "B"),
            ]
        )

        _ = dependency.testTarget.filteredMemos(by: "Apple", and: [])

        let displayed = dependency.testTarget.displayedMemos(editMode: .active)
        #expect(displayed.count == 2)
    }

    @Test
    func displayedMemos_inactive_returnsFilteredMemos() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        try seed(
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "Apple", content: "A"),
                Memo(title: "Banana", content: "B"),
            ]
        )

        _ = dependency.testTarget.filteredMemos(by: "Apple", and: [])

        let displayed = dependency.testTarget.displayedMemos(editMode: .inactive)
        #expect(displayed.count == 1)
        #expect(displayed.first?.title == "Apple")
    }

    // MARK: - Navigation Title

    @Test
    func navigationTitle_active_returnsSelectionCount() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        try seed(
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "A", content: "A"),
                Memo(title: "B", content: "B"),
            ]
        )

        dependency.testTarget.selectAll()
        #expect(dependency.testTarget.navigationTitle(editMode: .active) == "Memos (2/2)")
    }

    @Test
    func navigationTitle_inactive_filtering_returnsFilteredCount() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        try seed(
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "Apple", content: "A"),
                Memo(title: "Banana", content: "B"),
            ]
        )

        _ = dependency.testTarget.filteredMemos(by: "Apple", and: [])

        #expect(
            dependency.testTarget.navigationTitle(editMode: .inactive) == "Memos (1/2)"
        )
    }

    @Test
    func navigationTitle_inactive_noFilter_returnsTotalCount() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        try seed(
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "A", content: "A"),
                Memo(title: "B", content: "B"),
            ]
        )

        #expect(dependency.testTarget.navigationTitle(editMode: .inactive) == "Memos (2)")
    }

    // MARK: - Selection

    @Test
    func toggleSelection_togglesMembership() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let id = UUID()
        dependency.testTarget.toggleSelection(for: id)
        #expect(dependency.testTarget.selection.contains(id))

        dependency.testTarget.toggleSelection(for: id)
        #expect(!dependency.testTarget.selection.contains(id))
    }

    @Test
    func selectAllAndDeselectAll_workAsExpected() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        try seed(
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "A", content: "A"),
                Memo(title: "B", content: "B"),
            ]
        )

        dependency.testTarget.selectAll()
        #expect(dependency.testTarget.selection.count == 2)

        dependency.testTarget.deselectAll()
        #expect(dependency.testTarget.selection.isEmpty)
    }

    @Test
    func selectedMemos_returnsSelectedOnly() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let memo1 = Memo(title: "A", content: "A")
        let memo2 = Memo(title: "B", content: "B")
        try seed(
            context: dependency.memoRepository.modelContext,
            memos: [memo1, memo2]
        )

        dependency.testTarget.selection = [memo2.id]

        let selected = dependency.testTarget.selectedMemos()
        #expect(selected.count == 1)
        #expect(selected.first?.id == memo2.id)
    }

    // MARK: - Memos Changed

    @Test
    func handleMemosChanged_active_emptyNewMemos_clearsSelection() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.testTarget.selection = [UUID()]
        dependency.testTarget.handleMemosChanged(
            oldMemos: [Memo(title: "A", content: "A")],
            newMemos: [],
            editMode: .active
        )

        #expect(dependency.testTarget.selection.isEmpty)
    }

    @Test
    func handleMemosChanged_inactive_newMemo_selectsNewMemo() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let oldMemo = Memo(title: "Old", content: "Old", order: 1)
        let newMemo = Memo(title: "New", content: "New", order: 2)

        dependency.testTarget.handleMemosChanged(
            oldMemos: [oldMemo],
            newMemos: [oldMemo, newMemo],
            editMode: .inactive
        )

        #expect(dependency.testTarget.selectedMemo?.id == newMemo.id)
        #expect(dependency.testTarget.selection.isEmpty)
    }

    @Test
    func handleMemosChanged_inactive_emptyNewMemos_clearsSelectedMemoAndFilter() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        try seed(
            context: dependency.memoRepository.modelContext,
            memos: [Memo(title: "A", content: "A")]
        )

        let testTarget = dependency.testTarget
        testTarget.selectedMemo = Memo(title: "X", content: "X")
        _ = testTarget.filteredMemos(by: "A", and: [])

        testTarget.handleMemosChanged(
            oldMemos: [Memo(title: "A", content: "A")],
            newMemos: [],
            editMode: .inactive
        )

        #expect(testTarget.selectedMemo == nil)
        #expect(testTarget.filterQuery == "")
        #expect(!testTarget.isFiltering)
    }

    // MARK: - UI Actions

    @Test
    func onDuplicateMemo_success_returnsToast() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let memo = Memo(title: "A", content: "A")
        try seed(context: dependency.memoRepository.modelContext, memos: [memo])

        let result = dependency.testTarget.onDuplicateMemo(memo)
        #expect(result == .toast("Successfully duplicated!"))
    }

    @Test
    func onDeleteMemos_selectedDeleted_returnsNilAndToast() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let memo1 = Memo(title: "A", content: "A")
        let memo2 = Memo(title: "B", content: "B")
        try seed(
            context: dependency.memoRepository.modelContext,
            memos: [memo1, memo2]
        )

        let output = dependency.testTarget.onDeleteMemos(
            [memo1],
            currentSelectedMemo: memo1
        )

        #expect(output.newSelectedMemo == nil)
        #expect(output.result == .toast("Successfully deleted!"))
    }

    @Test
    func onDeleteMemos_selectedNotDeleted_keepsSelectionAndToast() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let memo1 = Memo(title: "A", content: "A")
        let memo2 = Memo(title: "B", content: "B")
        try seed(
            context: dependency.memoRepository.modelContext,
            memos: [memo1, memo2]
        )

        let output = dependency.testTarget.onDeleteMemos(
            [memo2],
            currentSelectedMemo: memo1
        )

        #expect(output.newSelectedMemo?.id == memo1.id)
        #expect(output.result == .toast("Successfully deleted!"))
    }

    @Test
    func onDeleteMemos_selectedDeleted_returnsNilSelectionAndToast() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let memo1 = Memo(title: "A", content: "A")
        let memo2 = Memo(title: "B", content: "B")
        try seed(
            context: dependency.memoRepository.modelContext,
            memos: [memo1, memo2]
        )

        let output = dependency.testTarget.onDeleteMemos(
            [memo1],
            currentSelectedMemo: memo1
        )

        #expect(output.newSelectedMemo == nil)
        #expect(output.result == .toast("Successfully deleted!"))
    }

    @Test
    func onMoveMemo_success_returnsNone() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        try seed(
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "A", content: "A"),
                Memo(title: "B", content: "B"),
                Memo(title: "C", content: "C"),
            ]
        )

        let result = dependency.testTarget.onMoveMemo(
            from: IndexSet(integer: 2),
            to: 1
        )
        #expect(result == .none)
    }

    @Test
    func onMoveMemo_invalidSource_returnsAlert() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        try seed(
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "A", content: "A"),
                Memo(title: "B", content: "B"),
            ]
        )

        let result = dependency.testTarget.onMoveMemo(
            from: IndexSet(integer: 999),
            to: 1
        )

        if case .alert(.error, _) = result {
            #expect(Bool(true))
        }
        else {
            #expect(Bool(false))
        }
    }

    @Test
    func onProtectMemos_authSuccess_returnsNoneAndProtects() async throws {
        let dependency = try Dependency(authenticateHandler: { true })
        defer { dependency.removeUserDefaults() }

        try seed(
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "A", content: "A", protected: false),
                Memo(title: "B", content: "B", protected: false),
            ]
        )

        let memos = try dependency.memoRepository.memos()
        let result = await dependency.testTarget.onProtectMemos(memos)

        #expect(result == .none)
        #expect(try dependency.memoRepository.memos().allSatisfy(\.protected))
    }

    @Test
    func onProtectMemos_authFailure_returnsAlert() async throws {
        enum DummyError: Error { case failed }

        let dependency = try Dependency(
            authenticateHandler: { throw DummyError.failed }
        )
        defer { dependency.removeUserDefaults() }

        try seed(
            context: dependency.memoRepository.modelContext,
            memos: [Memo(title: "A", content: "A", protected: false)]
        )

        let memos = try dependency.memoRepository.memos()
        let result = await dependency.testTarget.onProtectMemos(memos)

        if case .alert(.error, _) = result {
            #expect(Bool(true))
        }
        else {
            #expect(Bool(false))
        }
    }

    @Test
    func onUnprotectMemos_authSuccess_returnsNoneAndUnprotects() async throws {
        let dependency = try Dependency(authenticateHandler: { true })
        defer { dependency.removeUserDefaults() }

        try seed(
            context: dependency.memoRepository.modelContext,
            memos: [
                Memo(title: "A", content: "A", protected: true),
                Memo(title: "B", content: "B", protected: true),
            ]
        )

        let memos = try dependency.memoRepository.memos()
        let result = await dependency.testTarget.onUnprotectMemos(memos)

        #expect(result == .none)
        #expect(try dependency.memoRepository.memos().allSatisfy { !$0.protected })
    }

    @Test
    func onUnprotectMemos_authFailure_returnsAlert() async throws {
        enum DummyError: Error { case failed }

        let dependency = try Dependency(
            authenticateHandler: { throw DummyError.failed }
        )
        defer { dependency.removeUserDefaults() }

        try seed(
            context: dependency.memoRepository.modelContext,
            memos: [Memo(title: "A", content: "A", protected: true)]
        )

        let memos = try dependency.memoRepository.memos()
        let result = await dependency.testTarget.onUnprotectMemos(memos)

        if case .alert(.error, _) = result {
            #expect(Bool(true))
        }
        else {
            #expect(Bool(false))
        }
    }

    // MARK: - Preferences

    @Test
    func getTitleLineLimit() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setTitleLineLimit(3)
        #expect(dependency.testTarget.getTitleLineLimit() == 3)
    }

    @Test
    func getTitleFontSize() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setTitleFontSize(16.0)
        #expect(dependency.testTarget.getTitleFontSize() == 16.0)
    }

    @Test
    func getTitleLineSpacing() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setTitleLineSpacing(.zero)
        #expect(dependency.testTarget.getTitleLineSpacing() == .zero)
    }

    @Test
    func getShowInfo() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setShowInfo(false)
        #expect(!dependency.testTarget.getShowInfo())
    }

    // MARK: - Factory

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

        #expect(editViewModel.tags.map(\.id) == [tag.id])
        #expect(editViewModel.memo == nil)

        dependency.userDefaultsRepository.setContentFontSize(24.0)
        #expect(editViewModel.getContentFontSize() == 24.0)

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

        let selectViewModel = filterViewModel.makeSelectTagViewModel()

        #expect(selectViewModel.tags.map(\.id) == [tag.id])
        #expect(selectViewModel.titleLineLimit == 4)
        #expect(selectViewModel.titleFontSize == 24.0)
        #expect(selectViewModel.titleLineSpacing == 2.0)
    }

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

        memo.content = "Updated Content"
        #expect(previewViewModel.displayContent == "Updated Content")
    }

    // MARK: - Save Notification

    @Test
    func saveInObservedContext_refreshesMemos() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let context = dependency.memoRepository.modelContext
        context.autosaveEnabled = false

        let memo = Memo(title: "New Memo", content: "Content", order: 1)
        context.insert(memo)

        #expect(dependency.testTarget.memos.isEmpty)

        try context.save()

        #expect(dependency.testTarget.memos.map(\.id) == [memo.id])
    }

    @Test
    func saveInUnrelatedContext_doesNotRefreshMemos() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let context = dependency.memoRepository.modelContext
        context.autosaveEnabled = false

        let pendingMemo = Memo(
            title: "Pending Memo",
            content: "Content",
            order: 1
        )
        context.insert(pendingMemo)

        #expect(dependency.testTarget.memos.isEmpty)
        #expect(try dependency.memoRepository.memos().map(\.id) == [pendingMemo.id])

        let otherContainer = try ModelContainer(
            for: Memo.self,
            Tag.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let otherContext = otherContainer.mainContext
        otherContext.autosaveEnabled = false
        otherContext.insert(Memo(title: "Other", content: "Other"))
        try otherContext.save()

        #expect(dependency.testTarget.memos.isEmpty)

        try context.save()
        #expect(dependency.testTarget.memos.map(\.id) == [pendingMemo.id])
    }

    @Test(arguments: [false, true])
    func tagSaveFailure_preservesMemoListAndFilter(isDeletion: Bool) throws {
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

        // 初期データは通常の Repository で保存する。
        let setupTagRepository = TagRepository(modelContext: context)
        let memoRepository = MemoRepository(modelContext: context)

        let tag = Tag(title: "Original Tag", color: "#000000")
        try setupTagRepository.add(tag)

        let taggedMemo = Memo(title: "Tagged Memo", content: "A")
        let untaggedMemo = Memo(title: "Untagged Memo", content: "B")
        try memoRepository.add(taggedMemo, tags: [tag])
        try memoRepository.add(untaggedMemo)

        let viewModel = MemosViewModel(
            memoRepository: memoRepository,
            userDefaultsRepository: support.userDefaultsRepository
        )
        viewModel.filterTags = [tag]
        viewModel.selectedMemo = taggedMemo

        #expect(viewModel.isFiltering)
        #expect(viewModel.memos.map(\.id) == [taggedMemo.id, untaggedMemo.id])
        #expect(viewModel.filteredMemos.map(\.id) == [taggedMemo.id])

        // タグの保存通知後に失敗する状況を模擬する。
        let failingTagRepository = TagRepository(modelContext: context) { context in
            NotificationCenter.default.post(
                name: ModelContext.willSave,
                object: context
            )
            throw SimulatedSaveError()
        }

        #expect(throws: SimulatedSaveError.self) {
            if isDeletion {
                try failingTagRepository.delete([tag])
            }
            else {
                try failingTagRepository.update(
                    tag,
                    title: "Changed Tag",
                    color: "#FF0000"
                )
            }
        }

        // タグとメモの関連は保存前の状態に戻る。
        #expect(tag.title == "Original Tag")
        #expect(tag.color == "#000000")
        #expect(taggedMemo.tags.map(\.id) == [tag.id])
        #expect(tag.memos.map(\.id).contains(taggedMemo.id))
        #expect(!context.hasChanges)

        // 一覧・選択・フィルター条件と結果も維持される。
        #expect(viewModel.memos.map(\.id) == [taggedMemo.id, untaggedMemo.id])
        #expect(viewModel.selectedMemo?.id == taggedMemo.id)
        #expect(viewModel.isFiltering)
        #expect(viewModel.filterTags.map(\.id) == [tag.id])
        #expect(viewModel.filteredMemos.map(\.id) == [taggedMemo.id])

        // 別コンテキストからも保存済みの状態を確認する。
        let verificationContext = ModelContext(container)
        let savedTags = try verificationContext.fetch(FetchDescriptor<Tag>())
        let savedMemos = try verificationContext.fetch(FetchDescriptor<Memo>())

        let savedTag = try #require(savedTags.first { $0.id == tag.id })
        let savedMemo = try #require(savedMemos.first { $0.id == taggedMemo.id })

        #expect(savedTag.title == "Original Tag")
        #expect(savedTag.color == "#000000")
        #expect(savedMemo.tags.map(\.id) == [tag.id])
    }

    // MARK: - Test Data

    /// テストデータをコンテキストにまとめて登録・保存する。
    ///
    /// Repository の pendingChanges チェックに未保存のタグが
    /// 引っかからないよう、準備段階では Repository を使用しない。
    private func seed(
        context: ModelContext,
        tags: [Tag] = [],
        memos: [Memo]
    ) throws {
        context.autosaveEnabled = false

        for (index, memo) in memos.enumerated() {
            memo.order = index + 1
        }

        for memo in memos where memo.modelContext == nil {
            context.insert(memo)
        }

        for tag in tags where tag.modelContext == nil {
            context.insert(tag)
        }

        try context.save()
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
            testTarget = MemosViewModel(
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
