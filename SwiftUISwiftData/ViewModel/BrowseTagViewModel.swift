//
//  BrowseTagViewModel.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

internal import Combine
import SwiftData

/// BrowseTagViewModel is an observable object that manages the state and interactions for the ContentView, including fetching, deleting, renumbering, and moving tags using the TagRepository.
final class BrowseTagViewModel: ObservableObject {
    /// The userDefaultsRepository property is an instance of UserDefaultsRepository, which is used to manage the UserDefaults in the application.
    ///
    /// It provides functions in the userDefaultsRepository.
    private let userDefaultsRepository: UserDefaultsRepository

    init(userDefaultsRepository: UserDefaultsRepository) {
        self.userDefaultsRepository = userDefaultsRepository
    }

    func getShowInfo() -> Bool {
        userDefaultsRepository.getShowInfo()
    }
}
