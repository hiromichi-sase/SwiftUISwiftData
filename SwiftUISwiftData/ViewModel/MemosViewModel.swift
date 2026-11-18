//
//  MemosViewModel.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/04.
//

internal import Combine
import SwiftData
import SwiftUI

@MainActor
final class MemosViewModel: ObservableObject {
    enum MoveMemoValidationError: Error {
        case invalidSource
        case invalidDestination
    }

    @Published
    private(set) var memos: [Memo] = []
    @Published
    private(set) var filteredMemos: [Memo] = []
    @Published
    private(set) var keywordsForFiltering: [String] = []
    @Published
    var filterQuery: String = ""
    @Published
    var filterTags: [Tag] = []
    @Published
    private(set) var isFiltering = false
    @Published
    var selectedMemo: Memo?
    @Published
    var selection: Set<UUID> = []

    private let memoRepository: MemoRepository
    private let userDefaultsRepository: UserDefaultsRepository
    private var cancellables = Set<AnyCancellable>()
    private var memoDuplicateSource: Memo?

    init(
        memoRepository: MemoRepository,
        userDefaultsRepository: UserDefaultsRepository
    ) {
        self.memoRepository = memoRepository
        self.userDefaultsRepository = userDefaultsRepository

        fetchMemos()
        applyFilter()
        setupNotification()
        setupFilterObservers()
    }

    private func setupNotification() {
        NotificationCenter.default
            .publisher(for: ModelContext.willSave, object: memoRepository.modelContext)
            .sink { [weak self] _ in
                guard let self else { return }
                self.fetchMemos()
                self.applyFilter()
            }
            .store(in: &cancellables)
    }

    private func setupFilterObservers() {
        Publishers.CombineLatest($filterQuery, $filterTags)
            .sink { [weak self] _, _ in
                self?.applyFilter()
            }
            .store(in: &cancellables)
    }

    private func hasAnyMatch(_ memo: Memo, keywords: [String], tags: [Tag]) -> Bool {
        keywords.contains { memo.title.lowercased().contains($0.lowercased()) } || tags.contains { memo.tags.contains($0) }
    }

    func applyFilter() {
        let trimmed = filterQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        let keywords = trimmed.split(separator: " ").map(String.init)
        keywordsForFiltering = keywords

        let active = !trimmed.isEmpty || !filterTags.isEmpty
        isFiltering = active

        guard active else {
            filteredMemos = memos
            return
        }

        filteredMemos = memos.filter { hasAnyMatch($0, keywords: keywords, tags: filterTags) }
    }

    func clearFilter() {
        filterQuery = ""
        filterTags = []
        keywordsForFiltering = []
        isFiltering = false
        filteredMemos = memos
    }

    // Backward-compatible helper
    func filteredMemos(by keywords: String, and tags: [Tag]) -> [Memo] {
        filterQuery = keywords
        filterTags = tags
        applyFilter()
        return filteredMemos
    }

    private func fetchMemos() {
        do {
            memos = try memoRepository.memos()
        }
        catch {
            memos = []
        }
    }

    func displayedMemos(editMode: EditMode) -> [Memo] {
        editMode.isEditing ? memos : filteredMemos
    }

    func navigationTitle(editMode: EditMode) -> String {
        if editMode.isEditing {
            return "Memos (\(selection.count)/\(memos.count))"
        }
        if isFiltering {
            return "Memos (\(filteredMemos.count)/\(memos.count))"
        }
        return "Memos (\(memos.count))"
    }

    func toggleSelection(for id: UUID) {
        if selection.contains(id) {
            selection.remove(id)
        }
        else {
            selection.insert(id)
        }
    }

    func selectAll() {
        selection = Set(memos.map(\.id))
    }

    func deselectAll() {
        selection.removeAll()
    }

    func selectedMemos() -> [Memo] {
        memos.filter { selection.contains($0.id) }
    }

    func handleMemosChanged(
        oldMemos: [Memo],
        newMemos: [Memo],
        editMode: EditMode
    ) {
        switch editMode {
            case .active:
                if newMemos.isEmpty {
                    selection.removeAll()
                }
            case .inactive:
                if let newMemo = newMemos.first(where: { !oldMemos.contains($0) }) {
                    if let memoDuplicateSource, memoDuplicateSource.order + 1 == newMemo.order {
                        self.memoDuplicateSource = nil
                        return
                    }
                    selection.removeAll()
                    selectedMemo = newMemo
                }
                else if newMemos.isEmpty {
                    selectedMemo = nil
                    clearFilter()
                }
            default:
                break
        }
    }

    func duplicate(_ memo: Memo) throws {
        memoDuplicateSource = memo
        try memoRepository.duplicate(memo)
    }

    func delete(_ memos: [Memo]) throws {
        try memoRepository.delete(memos)
    }

    func moveMemo(from source: [Int], to destination: Int) throws {
        let count = memos.count
        guard count > 0 else { return }
        guard !source.isEmpty else { return }

        guard source.allSatisfy({ $0 >= 0 && $0 < count }) else {
            throw MoveMemoValidationError.invalidSource
        }

        guard destination >= 0 && destination <= count else {
            throw MoveMemoValidationError.invalidDestination
        }

        try memoRepository.moveMemo(from: source, to: destination)
    }

    func protect(_ memos: [Memo]) throws {
        try memoRepository.protect(memos)
    }

    func unprotect(_ memos: [Memo]) throws {
        try memoRepository.unprotect(memos)
    }

    func getTitleLineLimit() -> Int {
        userDefaultsRepository.getTitleLineLimit()
    }

    func getTitleFontSize() -> Float {
        userDefaultsRepository.getTitleFontSize()
    }

    func getTitleLineSpacing() -> Float {
        userDefaultsRepository.getTitleLineSpacing()
    }

    func getShowInfo() -> Bool {
        userDefaultsRepository.getShowInfo()
    }
}
