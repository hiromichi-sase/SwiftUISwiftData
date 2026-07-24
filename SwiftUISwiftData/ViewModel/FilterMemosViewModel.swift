//
//  FilterMemosViewModel.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/21.
//

internal import Combine
import SwiftData

/// FilterMemosViewModel is an observable object that manages the state and interactions for the ContentView, including fetching, deleting, renumbering, and moving tags using the TagRepository.
final class FilterMemosViewModel: ObservableObject {
    /// The userDefaultsRepository property is an instance of UserDefaultsRepository, which is used to manage the UserDefaults in the application.
    ///
    /// It provides functions in the userDefaultsRepository.
    private let userDefaultsRepository: UserDefaultsRepository
    /// An array of Tag objects that are published to update the UI when changes occur.
    private(set) var tags: [Tag] = []
    private let suiteName: String?

    init(
        tagRepository: TagRepository,
        userDefaultsRepository: UserDefaultsRepository,
        suiteName: String? = nil,
    ) {
        tags = tagRepository.tags()
        self.userDefaultsRepository = userDefaultsRepository
        self.suiteName = suiteName
    }

    func getDivideKeywordsBySpace() -> Bool {
        userDefaultsRepository.getDivideKeywordsBySpace()
    }

    func setDivideKeywordsBySpace(_ value: Bool) {
        userDefaultsRepository.setDivideKeywordsBySpace(value)
    }
}
