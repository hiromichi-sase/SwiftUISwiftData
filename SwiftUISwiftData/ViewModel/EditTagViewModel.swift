//
//  EditTagViewModel.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import Foundation

protocol TagRepositoryProtocol {
    func add(_ tag: Tag) throws
    func update(_ tag: Tag, title: String, color: String) throws
}

protocol UserDefaultsRepositoryProtocol {
    func getShowInfo() -> Bool
    func getDefaultTagColor() -> String
}

extension TagRepository: TagRepositoryProtocol {}
extension UserDefaultsRepository: UserDefaultsRepositoryProtocol {}

@Observable
@MainActor
final class EditTagViewModel {
    enum AlertType: Identifiable, Equatable {
        case close
        case error

        var id: Self { self }
    }

    var title: String
    var colorString: String

    var toastMessage: String = ""
    var currentAlert: AlertType?
    var errorMessage: String = ""
    var shouldDismiss: Bool = false
    private(set) var isSaving: Bool = false

    private let tagRepository: TagRepositoryProtocol
    private let userDefaultsRepository: UserDefaultsRepositoryProtocol

    private(set) var tag: Tag?

    private var initialTitle: String
    private var initialColor: String

    init(
        tag: Tag? = nil,
        tagRepository: TagRepositoryProtocol,
        userDefaultsRepository: UserDefaultsRepositoryProtocol
    ) {
        self.tagRepository = tagRepository
        self.userDefaultsRepository = userDefaultsRepository
        self.tag = tag

        let defaultColor = userDefaultsRepository.getDefaultTagColor()
        let startTitle = tag?.title ?? ""
        let startColor = tag?.color ?? defaultColor

        self.title = startTitle
        self.colorString = startColor
        self.initialTitle = startTitle
        self.initialColor = startColor
    }

    var navigationTitle: String {
        tag?.title ?? "Add Tag"
    }

    var showInfo: Bool {
        userDefaultsRepository.getShowInfo() && tag != nil
    }

    var isTagUpdated: Bool {
        title != initialTitle || colorString != initialColor
    }

    var canSave: Bool {
        !isSaving && !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && isTagUpdated
    }

    func onTapClose() {
        if isTagUpdated {
            currentAlert = .close
        }
        else {
            shouldDismiss = true
        }
    }

    func onConfirmClose() {
        shouldDismiss = true
    }

    func saveTag() {
        guard canSave else { return }

        isSaving = true
        defer { isSaving = false }

        do {
            if let tag {
                try tagRepository.update(tag, title: title, color: colorString)
            }
            else {
                let newTag = Tag(title: title, color: colorString)
                try tagRepository.add(newTag)
                self.tag = newTag
            }

            initialTitle = title
            initialColor = colorString

            toastMessage = "Successfully saved!"
        }
        catch {
            errorMessage = error.localizedDescription
            currentAlert = .error
        }
    }
}
