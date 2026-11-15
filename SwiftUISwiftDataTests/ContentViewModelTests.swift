//
//  ContentViewModelTests.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/11/15.
//

import SwiftData
import SwiftUI
import Testing

@testable import SwiftUISwiftData

@MainActor
struct ContentViewModelTests {
    @Test
    func initialState_isDefault() throws {
        let sut = try makeSUT()

        #expect(sut.state.selectedSection == nil)
        #expect(sut.state.memosViewEditMode == .inactive)
        #expect(sut.state.selectedMemo == nil)
        #expect(sut.state.tagsViewEditMode == .inactive)
        #expect(sut.state.selectedTag == nil)
        #expect(sut.state.showingAddMemo == false)
    }

    @Test
    func openNewMemoFlowFromShortcut_resetsAndMovesToMemos() throws {
        let sut = try makeSUT()

        // 事前に状態を崩しておく
        sut.state.selectedSection = .tags
        sut.state.memosViewEditMode = .active
        sut.state.tagsViewEditMode = .active
        sut.state.showingAddMemo = false

        sut.openNewMemoFlowFromShortcut()

        #expect(sut.state.selectedSection == .memos)
        #expect(sut.state.memosViewEditMode == .inactive)
        #expect(sut.state.selectedMemo == nil)
        #expect(sut.state.tagsViewEditMode == .inactive)
        #expect(sut.state.selectedTag == nil)
        #expect(sut.state.showingAddMemo == true)
    }

    @Test
    func resetStateForSectionChange_toTags_clearsOnlyMemoSide() throws {
        let sut = try makeSUT()

        sut.state.selectedSection = .memos
        sut.state.memosViewEditMode = .active
        sut.state.tagsViewEditMode = .active

        sut.resetStateForSectionChange(.tags)

        #expect(sut.state.selectedSection == .tags)
        #expect(sut.state.memosViewEditMode == .inactive)
        #expect(sut.state.selectedMemo == nil)
        #expect(sut.state.tagsViewEditMode == .active)
    }

    @Test
    func resetStateForSectionChange_toMemos_clearsOnlyTagSide() throws {
        let sut = try makeSUT()

        sut.state.selectedSection = .tags
        sut.state.memosViewEditMode = .active
        sut.state.tagsViewEditMode = .active

        sut.resetStateForSectionChange(.memos)

        #expect(sut.state.selectedSection == .memos)
        #expect(sut.state.memosViewEditMode == .active)
        #expect(sut.state.tagsViewEditMode == .inactive)
        #expect(sut.state.selectedTag == nil)
    }

    @Test
    @MainActor
    func resetNavigationState_postsCloseNotification() async throws {
        let sut = try makeSUT()

        let notifications = NotificationCenter.default.notifications(
            named: .closeAllPresentedViewsFromShortcut
        )
        let iterator = notifications.makeAsyncIterator()

        sut.resetNavigationState()

        let received = await iterator.next()

        #expect(received != nil)
        #expect(sut.state.memosViewEditMode == .inactive)
        #expect(sut.state.selectedMemo == nil)
        #expect(sut.state.tagsViewEditMode == .inactive)
        #expect(sut.state.selectedTag == nil)
    }
}

@MainActor
extension ContentViewModelTests {
    func makeSUT() throws -> ContentViewModel {
        let schema = Schema([
            Memo.self,
            Tag.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let repository = MemoRepository(modelContext: container.mainContext)
        return ContentViewModel(memoRepository: repository)
    }
}
