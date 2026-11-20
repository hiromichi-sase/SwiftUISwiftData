//
//  ContentViewModelTests.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/11/15.
//

import SwiftUI
import Testing

@testable import SwiftUISwiftData

@Suite(.serialized)
@MainActor
struct ContentViewModelTests {
    @Test
    func initialState_isDefault() {
        let sut = makeSUT()

        #expect(sut.homeViewModel.selectedSection == nil)
        #expect(sut.state.memosViewEditMode == .inactive)
        #expect(sut.state.selectedMemo == nil)
        #expect(sut.state.tagsViewEditMode == .inactive)
        #expect(sut.state.selectedTag == nil)
        #expect(sut.state.showingAddMemo == false)
    }

    @Test
    func openNewMemoFlowFromShortcut_resetsAndMovesToMemos() {
        let sut = makeSUT()

        sut.homeViewModel.select(.tags)
        sut.state.memosViewEditMode = .active
        sut.state.selectedMemo = makeMemo()
        sut.state.tagsViewEditMode = .active
        sut.state.selectedTag = makeTag()
        sut.state.showingAddMemo = false

        sut.openNewMemoFlowFromShortcut()

        #expect(sut.homeViewModel.selectedSection == .memos)
        #expect(sut.state.memosViewEditMode == .inactive)
        #expect(sut.state.selectedMemo == nil)
        #expect(sut.state.tagsViewEditMode == .inactive)
        #expect(sut.state.selectedTag == nil)
        #expect(sut.state.showingAddMemo)
    }

    @Test
    func resetStateForSectionChange_toTags_clearsOnlyMemoSide() {
        let sut = makeSUT()
        let tag = makeTag()

        sut.homeViewModel.select(.memos)
        sut.state.memosViewEditMode = .active
        sut.state.selectedMemo = makeMemo()
        sut.state.tagsViewEditMode = .active
        sut.state.selectedTag = tag

        sut.resetStateForSectionChange(.tags)

        #expect(sut.homeViewModel.selectedSection == .tags)
        #expect(sut.state.memosViewEditMode == .inactive)
        #expect(sut.state.selectedMemo == nil)
        #expect(sut.state.tagsViewEditMode == .active)
        #expect(sut.state.selectedTag == tag)
    }

    @Test
    func resetStateForSectionChange_toMemos_clearsOnlyTagSide() {
        let sut = makeSUT()
        let memo = makeMemo()

        sut.homeViewModel.select(.tags)
        sut.state.memosViewEditMode = .active
        sut.state.selectedMemo = memo
        sut.state.tagsViewEditMode = .active
        sut.state.selectedTag = makeTag()

        sut.resetStateForSectionChange(.memos)

        #expect(sut.homeViewModel.selectedSection == .memos)
        #expect(sut.state.memosViewEditMode == .active)
        #expect(sut.state.selectedMemo == memo)
        #expect(sut.state.tagsViewEditMode == .inactive)
        #expect(sut.state.selectedTag == nil)
    }

    @Test(arguments: [
        HomeViewModel.Section.settings,
        nil,
    ])
    func resetStateForSectionChange_toSettingsOrNil_clearsBothSides(
        section: HomeViewModel.Section?
    ) {
        let sut = makeSUT()

        sut.homeViewModel.select(.memos)
        sut.state.memosViewEditMode = .active
        sut.state.selectedMemo = makeMemo()
        sut.state.tagsViewEditMode = .active
        sut.state.selectedTag = makeTag()

        sut.resetStateForSectionChange(section)

        #expect(sut.homeViewModel.selectedSection == section)
        #expect(sut.state.memosViewEditMode == .inactive)
        #expect(sut.state.selectedMemo == nil)
        #expect(sut.state.tagsViewEditMode == .inactive)
        #expect(sut.state.selectedTag == nil)
    }

    @Test
    func resetNavigationState_postsCloseNotification() async {
        let sut = makeSUT()

        sut.homeViewModel.select(.tags)
        sut.state.memosViewEditMode = .active
        sut.state.selectedMemo = makeMemo()
        sut.state.tagsViewEditMode = .active
        sut.state.selectedTag = makeTag()

        await confirmation(
            "表示中の画面を閉じる通知が送信される",
            expectedCount: 1
        ) { confirmed in
            let token = NotificationCenter.default.addObserver(
                forName: .closeAllPresentedViewsFromShortcut,
                object: nil,
                queue: nil
            ) { _ in
                confirmed()
            }
            defer {
                NotificationCenter.default.removeObserver(token)
            }

            sut.resetNavigationState()
        }

        #expect(sut.homeViewModel.selectedSection == .tags)
        #expect(sut.state.memosViewEditMode == .inactive)
        #expect(sut.state.selectedMemo == nil)
        #expect(sut.state.tagsViewEditMode == .inactive)
        #expect(sut.state.selectedTag == nil)
    }

    private func makeSUT() -> ContentViewModel {
        ContentViewModel(
            homeViewModel: HomeViewModel(
                appNameProvider: { "SwiftUISwiftData" }
            )
        )
    }

    private func makeMemo() -> Memo {
        Memo(title: "Test Memo", content: "Test Content")
    }

    private func makeTag() -> Tag {
        Tag(title: "Test Tag", color: "#000000")
    }
}
