//
//  ContentViewModel.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/04.
//

import SwiftUI

/// メモ・タグ画面間で共有するナビゲーション状態。
struct ContentViewState: Equatable {
    var memosViewEditMode: EditMode = .inactive
    var selectedMemo: Memo? = nil
    var tagsViewEditMode: EditMode = .inactive
    var selectedTag: Tag? = nil
    var showingAddMemo: Bool = false
}

@Observable
@MainActor
final class ContentViewModel {
    /// 選択セクションは HomeViewModel のみで保持する。
    let homeViewModel: HomeViewModel

    var state: ContentViewState

    init(
        homeViewModel: HomeViewModel = HomeViewModel(),
        initialState: ContentViewState = ContentViewState()
    ) {
        self.homeViewModel = homeViewModel
        state = initialState
    }

    /// ショートカットから新規メモ画面を開く。
    func openNewMemoFlowFromShortcut() {
        resetNavigationState()
        homeViewModel.select(.memos)
        state.showingAddMemo = true
    }

    /// メモ・タグの選択状態をリセットし、表示中の画面を閉じる。
    func resetNavigationState() {
        clearMemoSelectionState()
        clearTagSelectionState()

        NotificationCenter.default.post(
            name: .closeAllPresentedViewsFromShortcut,
            object: nil
        )
    }

    /// セクション変更時に、選択されていない側の状態をリセットする。
    func resetStateForSectionChange(_ section: HomeViewModel.Section?) {
        if homeViewModel.selectedSection != section {
            homeViewModel.select(section)
        }

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
