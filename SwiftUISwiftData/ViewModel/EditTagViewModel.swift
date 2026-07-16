//
//  EditTagViewModel.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

internal import Combine
import SwiftData

/// EditTagViewModel is responsible for handling the logic related to adding and updating tags.
///
/// It interacts with the TagRepository to perform these operations.
final class EditTagViewModel: ObservableObject {
    /// The tagRepository property is an instance of TagRepository, which is used to manage the tags in the application.
    ///
    /// It provides functions to add and update tags in the tagRepository.
    private let tagRepository: TagRepository
    /// The userDefaultsRepository property is an instance of UserDefaultsRepository, which is used to manage the UserDefaults in the application.
    ///
    /// It provides functions in the userDefaultsRepository.
    private let userDefaultsRepository: UserDefaultsRepository

    init(
        tagRepository: TagRepository,
        userDefaultsRepository: UserDefaultsRepository
    ) {
        self.tagRepository = tagRepository
        self.userDefaultsRepository = userDefaultsRepository
    }

    /// Adds a new tag to the tagRepository.
    ///
    /// This function takes a Tag object as a parameter and attempts to add it to the tagRepository. If an error occurs during the addition, it throws an error.
    /// - Parameter tag: The Tag object that needs to be added to the tagRepository.
    /// - throws: An error.
    func add(_ tag: Tag) throws {
        try tagRepository.add(tag)
    }

    /// Updates an existing tag in the tagRepository.
    ///
    /// This function takes a Tag object as a parameter and attempts to update it in the tagRepository. If an error occurs during the update, it throws an error.
    /// - Parameters:
    ///   - tag: The Tag object that needs to be updated in the tagRepository.
    ///   - title: The title that needs to be updated.
    ///   - color: The color that needs to be updated.
    /// - throws: An error.
    func update(_ tag: Tag, title: String, color: String) throws {
        try tagRepository.update(tag, title: title, color: color)
    }

    func getShowInfo() -> Bool {
        userDefaultsRepository.getShowInfo()
    }
}
