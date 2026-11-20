//
//  EditMemoViewModel.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/04.
//

import SwiftUI

@MainActor
@Observable
final class EditMemoViewModel {
    enum AlertType: Identifiable, Equatable {
        case close
        case error

        var id: Self { self }
    }

    private let memoRepository: MemoRepository
    private let tagRepository: TagRepository
    private let userDefaultsRepository: UserDefaultsRepository

    private(set) var memo: Memo?

    var title: String
    var titleToStore: String
    var content: String
    var selectedTags: [Tag]
    private(set) var tags: [Tag] = []

    var showTitleView = false
    var showSelectTagView = false
    var toastMessage = ""
    var error: (any Error)?
    var currentAlert: AlertType?

    init(
        memo: Memo? = nil,
        memoRepository: MemoRepository,
        tagRepository: TagRepository,
        userDefaultsRepository: UserDefaultsRepository
    ) {
        self.memo = memo
        self.memoRepository = memoRepository
        self.tagRepository = tagRepository
        self.userDefaultsRepository = userDefaultsRepository

        self.title = memo?.title ?? ""
        self.titleToStore = memo?.title ?? ""
        self.content = memo?.content ?? ""
        self.selectedTags = memo?.tags ?? []
        self.tags = (try? tagRepository.tags()) ?? []
    }

    // MARK: - Derived

    var navigationTitle: String {
        title
    }

    var memoUpdated: Bool {
        guard let memo else {
            return !title.isEmpty || !content.isEmpty || !selectedTags.isEmpty
        }

        return memo.title != title
            || memo.content != content
            || memo.tags.sortedByOrder != selectedTags.sortedByOrder
    }

    var canSave: Bool {
        memoUpdated && !showTitleView
    }

    var canOpenTagSelector: Bool {
        !showTitleView && !tags.isEmpty
    }

    // MARK: - Intents

    func onTapClose() {
        currentAlert = memoUpdated ? .close : nil
    }

    func onTapRename() {
        showTitleView = true
    }

    func submitRename() {
        showTitleView = false
        title = titleToStore
    }

    func cancelRename() {
        showTitleView = false
        titleToStore = title
    }

    func onTapTag() {
        showSelectTagView = true
    }

    func onReceiveCloseAllPresentedViews() {
        showSelectTagView = false
        showTitleView = false
        currentAlert = nil
    }

    func save() {
        if let memo {
            updateMemo(memo)
        }
        else {
            addMemo()
        }
    }

    // MARK: - Factory

    func makeSelectTagViewModel() -> SelectTagViewModel {
        SelectTagViewModel(
            tagRepository: tagRepository,
            userDefaultsRepository: userDefaultsRepository
        )
    }

    // MARK: - UseCases

    private func addMemo() {
        let newMemo = Memo(title: title, content: content, tags: selectedTags)
        do {
            try memoRepository.add(newMemo)
            memo = newMemo
            toastMessage = "Successfully saved!"
        }
        catch {
            self.error = error
            currentAlert = .error
        }
    }

    private func updateMemo(_ memo: Memo) {
        let oldTitle = memo.title
        let oldContent = memo.content
        let oldTags = memo.tags

        do {
            try memoRepository.update(memo, title: title, content: content, tags: selectedTags)
            toastMessage = "Successfully saved!"
        }
        catch {
            self.error = error
            currentAlert = .error

            memo.title = oldTitle
            memo.content = oldContent
            memo.tags = oldTags
        }
    }

    // MARK: - Preferences

    func getContentFontSize() -> Float {
        userDefaultsRepository.getContentFontSize()
    }

    func getContentLineSpacing() -> Float {
        userDefaultsRepository.getContentLineSpacing()
    }

    func getShowInfo() -> Bool {
        userDefaultsRepository.getShowInfo()
    }
}
