//
//  FilterMemosViewModel.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/21.
//

import SwiftData

/// メモのフィルター条件を編集・適用する ViewModel。
@Observable
@MainActor
final class FilterMemosViewModel {
    // MARK: - Types

    struct FilterApplyResult {
        let isFiltering: Bool
        let title: String
        let tags: [Tag]
        let selectedMemo: Memo?
    }

    // MARK: - Dependencies

    private let userDefaultsRepository: UserDefaultsRepository
    private let tagRepository: TagRepository?

    // MARK: - State

    /// 選択可能なタグ。
    private(set) var tags: [Tag] = []

    /// フィルター画面を開いたときの条件。
    private var originalTitle = ""
    private var originalTags: [Tag] = []

    /// 画面で編集中の条件。
    var editingTitle = ""
    var editingTags: [Tag] = []

    // MARK: - Initialization

    init(
        tagRepository: TagRepository,
        userDefaultsRepository: UserDefaultsRepository
    ) {
        self.tagRepository = tagRepository
        self.userDefaultsRepository = userDefaultsRepository
        tags = (try? tagRepository.tags()) ?? []
    }

    /// テスト・プレビュー用のイニシャライザ。
    init(
        tags: [Tag],
        userDefaultsRepository: UserDefaultsRepository
    ) {
        self.tagRepository = nil
        self.userDefaultsRepository = userDefaultsRepository
        self.tags = tags
    }

    // MARK: - Derived State

    var titleLineLimit: Int {
        userDefaultsRepository.getTitleLineLimit()
    }

    var titleFontSize: Float {
        userDefaultsRepository.getTitleFontSize()
    }

    var titleLineSpacing: Float {
        userDefaultsRepository.getTitleLineSpacing()
    }

    /// 編集値が初期値と同じ場合、Save ボタンを無効にする。
    var saveButtonDisabled: Bool {
        originalTitle == editingTitle
            && originalTags.sortedByOrder == editingTags.sortedByOrder
    }

    var hasFilteringCondition: Bool {
        !editingTitle.isEmpty || !editingTags.isEmpty
    }

    // MARK: - Intents

    /// 親画面のフィルター条件を初期値として設定する。
    func setInitialFilter(title: String, tags: [Tag]) {
        originalTitle = title
        originalTags = tags
        editingTitle = title
        editingTags = tags
    }

    /// 編集中の条件から適用結果を作成する。
    func buildSaveResult() -> FilterApplyResult {
        FilterApplyResult(
            isFiltering: hasFilteringCondition,
            title: editingTitle,
            tags: editingTags,
            selectedMemo: nil
        )
    }

    /// フィルターを解除する結果を作成する。
    func buildResetResult() -> FilterApplyResult {
        FilterApplyResult(
            isFiltering: false,
            title: "",
            tags: [],
            selectedMemo: nil
        )
    }

    // MARK: - Factory

    /// タグ選択画面用の ViewModel を作成する。
    func makeSelectTagViewModel() -> SelectTagViewModel {
        if let tagRepository {
            return SelectTagViewModel(
                tagRepository: tagRepository,
                userDefaultsRepository: userDefaultsRepository
            )
        }

        return SelectTagViewModel(
            tags: tags,
            userDefaultsRepository: userDefaultsRepository
        )
    }
}
