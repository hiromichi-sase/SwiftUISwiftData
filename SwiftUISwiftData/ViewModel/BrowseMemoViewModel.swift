//
//  BrowseMemoViewModel.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/04.
//

import SwiftData

@Observable
@MainActor
final class BrowseMemoViewModel {
    let memo: Memo
    private let userDefaultsRepository: UserDefaultsRepository
    var showingEditMemo = false

    init(
        memo: Memo,
        userDefaultsRepository: UserDefaultsRepository
    ) {
        self.memo = memo
        self.userDefaultsRepository = userDefaultsRepository
    }

    var isContentEmpty: Bool {
        memo.content.isEmpty
    }

    var displayContent: String {
        isContentEmpty ? CommonString.noContent : memo.content
    }

    var hasLink: Bool {
        userDefaultsRepository.getHasLink()
    }

    var contentFontSize: Float {
        userDefaultsRepository.getContentFontSize()
    }

    var contentLineSpacing: Float {
        userDefaultsRepository.getContentLineSpacing()
    }

    var showInfo: Bool {
        userDefaultsRepository.getShowInfo()
    }

    var title: String {
        memo.title
    }

    var isProtected: Bool {
        memo.protected
    }

    var tagsSortedByOrder: [Tag] {
        memo.tags.sortedByOrder
    }

    func editButtonTapped() {
        showingEditMemo = true
    }

    func dismissEdit() {
        showingEditMemo = false
    }
}
