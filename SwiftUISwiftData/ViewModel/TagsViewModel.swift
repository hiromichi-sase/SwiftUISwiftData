//
//  TagsViewModel.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

internal import Combine
import Foundation
import SwiftData

/// TagsViewModel is an observable object that manages the state and interactions for the ContentView, including fetching, deleting, renumbering, and moving tags using the TagRepository.
final class TagsViewModel: ObservableObject {
    /// An array of Tag objects that are published to update the UI when changes occur.
    @Published
    private(set) var tags: [Tag] = []
    /// The tagRepository property is an instance of TagRepository, which is used to manage the tags in the application.
    ///
    /// It provides functions to add and update tags in the tagRepository.
    private let tagRepository: TagRepository
    /// The userDefaultsRepository property is an instance of UserDefaultsRepository, which is used to manage the UserDefaults in the application.
    ///
    /// It provides functions in the userDefaultsRepository.
    private let userDefaultsRepository: UserDefaultsRepository
    private var cancellables = Set<AnyCancellable>()

    init(
        tagRepository: TagRepository,
        userDefaultsRepository: UserDefaultsRepository
    ) {
        self.tagRepository = tagRepository
        self.userDefaultsRepository = userDefaultsRepository
        fetchTags()
        setupNotification()
    }

    private func setupNotification() {
        NotificationCenter.default
            .publisher(for: ModelContext.willSave)
            .sink { [weak self] _ in
                Task { self?.fetchTags() }
            }
            .store(in: &cancellables)
    }

    /// Fetches tags from the tagRepository and updates the published tags array.
    private func fetchTags() {
        tags = tagRepository.tags()
    }

    /// Deletes the specified tags from the tagRepository and refreshes the tags list, and renumbers the order of tags in the tagRepository and refreshes the tags list.
    ///
    /// If an error occurs during the deletion, it throws an error.
    /// - Parameter tags: An array of Tag objects to be deleted.
    /// - throws: An error.
    func delete(_ tags: [Tag]) throws {
        try tagRepository.delete(tags)
    }

    /// Moves tags from the specified source indices to the destination index in the tagRepository, and refreshes the tags list after a short delay to ensure the changes are reflected in the UI.
    ///
    /// If an error occurs during the moving, it throws an error.
    /// - Parameters:
    ///   - source: An integer array representing the indices of the tag to be moved.
    ///   - destination: An integer representing the index to which the tags should be moved.
    /// - throws: An error.
    func moveTag(from source: [Int], to destination: Int) throws {
        try tagRepository.moveTag(from: source, to: destination)
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
