//
//  MemosViewModel.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/04.
//

import SwiftData
import SwiftUI

@Observable
@MainActor
final class MemosViewModel {
    enum MoveMemoValidationError: Error {
        case invalidSource
        case invalidDestination
    }

    enum ActionAlert: Equatable {
        case error
    }

    enum ActionResult: Equatable {
        case none
        case toast(String)
        case alert(ActionAlert, message: String?)
    }

    typealias AuthenticateHandler = @MainActor () async throws -> Bool

    private(set) var memos: [Memo] = []
    private(set) var filteredMemos: [Memo] = []
    private(set) var keywordsForFiltering: [String] = []

    var filterQuery: String = "" {
        didSet { applyFilter() }
    }

    var filterTags: [Tag] = [] {
        didSet { applyFilter() }
    }

    private(set) var isFiltering = false
    var selectedMemo: Memo?
    var selection: Set<UUID> = []

    @ObservationIgnored
    private let memoRepository: MemoRepository

    @ObservationIgnored
    private let userDefaultsRepository: UserDefaultsRepository

    @ObservationIgnored
    private let authenticateHandler: AuthenticateHandler

    @ObservationIgnored
    private var saveNotificationToken: NSObjectProtocol?

    @ObservationIgnored
    private var memoDuplicateSource: Memo?

    init(
        memoRepository: MemoRepository,
        userDefaultsRepository: UserDefaultsRepository,
        authenticateHandler: @escaping AuthenticateHandler = {
            let result = try await AuthenticationManager.shared.authenticate()
            guard result.success else {
                if let error = result.error {
                    throw error
                }
                throw NSError(
                    domain: "Authentication",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Authentication failed."]
                )
            }
            return true
        }
    ) {
        self.memoRepository = memoRepository
        self.userDefaultsRepository = userDefaultsRepository
        self.authenticateHandler = authenticateHandler

        fetchMemos()
        applyFilter()
        setupNotification()
    }

    private func setupNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleModelContextWillSave(_:)),
            name: ModelContext.willSave,
            object: memoRepository.modelContext
        )
    }

    @objc
    private func handleModelContextWillSave(_ notification: Notification) {
        fetchMemos()
        applyFilter()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func hasAnyMatch(_ memo: Memo, keywords: [String], tags: [Tag]) -> Bool {
        keywords.contains { memo.title.lowercased().contains($0.lowercased()) }
            || tags.contains { memo.tags.contains($0) }
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
        // didSet で applyFilter が走るため、最後に query をクリア
        filterTags = []
        keywordsForFiltering = []
        isFiltering = false
        filteredMemos = memos
        filterQuery = ""
    }

    // Backward-compatible helper
    func filteredMemos(by keywords: String, and tags: [Tag]) -> [Memo] {
        filterTags = tags
        filterQuery = keywords
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

    // MARK: - UI Action entry points (MVVM)

    func onDuplicateMemo(_ memo: Memo) -> ActionResult {
        do {
            try duplicate(memo)
            return .toast("Successfully duplicated!")
        }
        catch {
            return .alert(.error, message: error.localizedDescription)
        }
    }

    func onDeleteMemos(
        _ memosToDelete: [Memo],
        currentSelectedMemo: Memo?
    ) -> (result: ActionResult, newSelectedMemo: Memo?) {
        do {
            try delete(memosToDelete)

            var nextSelectedMemo = currentSelectedMemo
            if let selected = currentSelectedMemo, memosToDelete.contains(selected) {
                nextSelectedMemo = nil
                selectedMemo = nil
            }

            deselectAll()
            return (.toast("Successfully deleted!"), nextSelectedMemo)
        }
        catch {
            return (.alert(.error, message: error.localizedDescription), currentSelectedMemo)
        }
    }

    func onMoveMemo(from source: IndexSet, to destination: Int) -> ActionResult {
        do {
            try moveMemo(from: source.map { $0 }, to: destination)
            return .none
        }
        catch {
            return .alert(.error, message: error.localizedDescription)
        }
    }

    func onProtectMemos(_ memosToProtect: [Memo]) async -> ActionResult {
        do {
            guard try await authenticateHandler() else {
                return .none
            }
            try protect(memosToProtect)
            return .none
        }
        catch {
            return .alert(.error, message: error.localizedDescription)
        }
    }

    func onUnprotectMemos(_ memosToUnprotect: [Memo]) async -> ActionResult {
        do {
            guard try await authenticateHandler() else {
                return .none
            }
            try unprotect(memosToUnprotect)
            return .none
        }
        catch {
            return .alert(.error, message: error.localizedDescription)
        }
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
