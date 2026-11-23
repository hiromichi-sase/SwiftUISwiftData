//
//  TagsViewModel.swift
//  SwiftUISwiftData
//

internal import Combine
import Foundation
import SwiftData
import SwiftUI

@Observable
@MainActor
final class TagsViewModel {
    enum AlertType: Identifiable {
        case delete
        case error

        var id: Self { self }
    }

    /// タグ取得処理。
    ///
    /// テストでは失敗を模擬できる。
    typealias FetchTagsHandler = () throws -> [Tag]

    private(set) var tags: [Tag] = []
    var editMode: EditMode = .inactive
    var selectedTag: Tag?
    var selection: Set<UUID> = []
    var showingAddTag = false
    var tagToDelete: Tag?
    var toastMessage = ""
    var error: (any Error)?
    var currentAlert: AlertType?
    private(set) var scrollTargetID: UUID?

    /// 最後の取得に失敗した場合のエラーメッセージ。
    private(set) var fetchErrorMessage: String?

    private let tagRepository: TagRepository
    private let userDefaultsRepository: UserDefaultsRepository
    private let fetchTagsHandler: FetchTagsHandler
    private var cancellables = Set<AnyCancellable>()

    init(
        tagRepository: TagRepository,
        userDefaultsRepository: UserDefaultsRepository,
        fetchTagsHandler: FetchTagsHandler? = nil
    ) {
        self.tagRepository = tagRepository
        self.userDefaultsRepository = userDefaultsRepository

        if let fetchTagsHandler {
            self.fetchTagsHandler = fetchTagsHandler
        }
        else {
            self.fetchTagsHandler = {
                try tagRepository.tags()
            }
        }

        fetchTags()
        setupNotification()
    }

    // MARK: - Derived State

    var navigationTitle: String {
        if editMode.isEditing {
            return "Tags (\(selection.count)/\(tags.count))"
        }
        return "Tags (\(tags.count))"
    }

    var canDeleteInEditMode: Bool {
        !selection.isEmpty
    }

    var canSelectAll: Bool {
        selection.count != tags.count
    }

    // MARK: - UserDefaults

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

    // MARK: - Intents

    /// タグ一覧の取得を再試行する。
    func retryFetchTags() {
        fetchTags()
    }

    func onTapEdit() {
        selectedTag = nil
        editMode = .active
    }

    func onTapDone() {
        selection.removeAll()
        editMode = .inactive
    }

    func onTapAdd() {
        showingAddTag = true
    }

    func onTapDelete(tag: Tag?) {
        tagToDelete = tag
        currentAlert = .delete
    }

    func onTapRowInEditMode(_ tag: Tag) {
        if selection.contains(tag.id) {
            selection.remove(tag.id)
        }
        else {
            selection.insert(tag.id)
        }
    }

    func onTapRowInNormalMode(_ tag: Tag) {
        selectedTag = tag
    }

    func onTapPreview(_ tag: Tag) {
        selectedTag = tag
    }

    func onTapSelectAll() {
        selection = Set(tags.map(\.id))
    }

    func onTapDeselectAll() {
        selection.removeAll()
    }

    func onCloseAllPresentedViews() {
        showingAddTag = false
        selectedTag = nil
        selection.removeAll()
        editMode = .inactive
        tagToDelete = nil
        currentAlert = nil
    }

    func confirmDelete() {
        let targets: [Tag]
        if editMode.isEditing {
            targets = tags.filter { selection.contains($0.id) }
        }
        else if let tagToDelete {
            targets = [tagToDelete]
        }
        else {
            targets = []
        }

        guard !targets.isEmpty else { return }

        do {
            try tagRepository.delete(targets)

            if let selected = selectedTag,
                targets.contains(where: { $0.id == selected.id })
            {
                selectedTag = nil
            }

            selection.removeAll()
            tagToDelete = nil
            toastMessage = "Successfully deleted!"
            fetchTags()
        }
        catch {
            self.error = error
            currentAlert = .error
        }
    }

    func moveTag(from source: IndexSet, to destination: Int) {
        do {
            try tagRepository.moveTag(
                from: Array(source),
                to: destination
            )
            fetchTags()
        }
        catch {
            self.error = error
            currentAlert = .error
        }
    }

    func onTagsChanged(oldTags: [Tag], newTags: [Tag]) {
        switch editMode {
            case .active:
                if newTags.isEmpty {
                    selection.removeAll()
                    editMode = .inactive
                }
            case .inactive:
                let oldIDs = Set(oldTags.map(\.id))
                if let newTag = newTags.first(
                    where: { !oldIDs.contains($0.id) }
                ) {
                    selection.removeAll()
                    selectedTag = newTag
                    scrollTargetID = newTag.id
                }
            default:
                break
        }
    }

    func consumeScrollTargetID() -> UUID? {
        defer { scrollTargetID = nil }
        return scrollTargetID
    }

    // MARK: - Private

    private func setupNotification() {
        NotificationCenter.default
            .publisher(
                for: ModelContext.didSave,
                object: tagRepository.modelContext
            )
            .sink { [weak self] _ in
                self?.fetchTags()
            }
            .store(in: &cancellables)
    }

    private func fetchTags() {
        do {
            let fetchedTags = try fetchTagsHandler()
            tags = fetchedTags
            fetchErrorMessage = nil
        }
        catch {
            // 取得失敗時は、直前の一覧を空配列で上書きしない。
            fetchErrorMessage = error.localizedDescription
        }
    }

    // MARK: - Factory

    func makeEditTagViewModel() -> EditTagViewModel {
        EditTagViewModel(
            tagRepository: tagRepository,
            userDefaultsRepository: userDefaultsRepository
        )
    }
}
