//
//  BrowseMemoViewModel.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/04.
//

import SwiftData
internal import Combine

/// BrowseMemoViewModel is an observable object that manages the state and interactions for the ContentView, including fetching, deleting, renumbering, and moving memos using the MemoRepository.
class BrowseMemoViewModel: ObservableObject {
    /// The memoRepository property is an instance of MemoRepository, which is used to manage the memos in the application. It provides functions to add and update memos in the memoRepository.
    private let memoRepository: MemoRepository
    /// The userDefaultsRepository property is an instance of UserDefaultsRepository, which is used to manage the UserDefaults in the application. It provides functions in the userDefaultsRepository.
    private let userDefaultsRepository: UserDefaultsRepository

    init(
        memoRepository: MemoRepository,
        userDefaultsRepository: UserDefaultsRepository
    ) {
        self.memoRepository = memoRepository
        self.userDefaultsRepository = userDefaultsRepository
    }

    /// The model context used for performing SwiftData operations, accessed from the memoRepository.
    var modelContext: ModelContext {
        memoRepository.modelContext
    }

    func getBrowseLink() -> Bool {
        userDefaultsRepository.getBrowseLink()
    }
}
