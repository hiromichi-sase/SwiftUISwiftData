//
//  ContentViewModel.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/04.
//

import SwiftData
import SwiftUI

struct ContentViewState: Equatable {
    var selectedSection: HomeViewModel.Section? = nil
    var memosViewEditMode: EditMode = .inactive
    var selectedMemo: Memo? = nil
    var tagsViewEditMode: EditMode = .inactive
    var selectedTag: Tag? = nil
    var showingAddMemo: Bool = false
}

@Observable
@MainActor
final class ContentViewModel {
    var state: ContentViewState

    private let memoRepository: MemoRepository

    init(
        memoRepository: MemoRepository,
        initialState: ContentViewState = ContentViewState()
    ) {
        self.memoRepository = memoRepository
        self.state = initialState
    }

    var modelContext: ModelContext {
        memoRepository.modelContext
    }

    func openNewMemoFlowFromShortcut() {
        resetNavigationState()
        state.selectedSection = .memos
        state.showingAddMemo = true
    }

    func resetNavigationState() {
        clearMemoSelectionState()
        clearTagSelectionState()
        NotificationCenter.default.post(name: .closeAllPresentedViewsFromShortcut, object: nil)
    }

    func resetStateForSectionChange(_ section: HomeViewModel.Section?) {
        state.selectedSection = section

        if section != .memos {
            clearMemoSelectionState()
        }

        if section != .tags {
            clearTagSelectionState()
        }
    }

    func clearMemoSelectionState() {
        state.memosViewEditMode = .inactive
        state.selectedMemo = nil
    }

    func clearTagSelectionState() {
        state.tagsViewEditMode = .inactive
        state.selectedTag = nil
    }
}
