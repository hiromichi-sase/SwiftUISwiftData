//
//  SelectTagViewModel.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

internal import Combine
import SwiftData

/// SelectTagViewModel is an observable object that manages the state and interactions for the ContentView, including fetching, deleting, renumbering, and moving tags using the TagRepository.
final class SelectTagViewModel: ObservableObject {
    /// An array of Tag objects that are published to update the UI when changes occur.
    private(set) var tags: [Tag] = []
    /// The userDefaultsRepository property is an instance of UserDefaultsRepository, which is used to manage the UserDefaults in the application.
    ///
    /// It provides functions in the userDefaultsRepository.
    private let userDefaultsRepository: UserDefaultsRepository

    init(
        tagRepository: TagRepository,
        userDefaultsRepository: UserDefaultsRepository
    ) {
        self.userDefaultsRepository = userDefaultsRepository
        tags = (try? tagRepository.tags()) ?? []
    }

    private func value<T>(_ getter: (UserDefaultsRepository) -> () -> T) -> T {
        getter(userDefaultsRepository)()
    }

    func getTitleLineLimit() -> Int {
        value(UserDefaultsRepository.getTitleLineLimit)
    }

    func getTitleFontSize() -> Float {
        value(UserDefaultsRepository.getTitleFontSize)
    }

    func getTitleLineSpacing() -> Float {
        value(UserDefaultsRepository.getTitleLineSpacing)
    }
}
