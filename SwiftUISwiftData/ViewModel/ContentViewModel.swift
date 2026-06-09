//
//  ContentViewModel.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/04.
//

import SwiftData
internal import Combine

/// ContentViewModel is an observable object that manages the state and interactions for the ContentView, including fetching, deleting, renumbering, and moving memos using the MemoRepository.
final class ContentViewModel: ObservableObject {
    /// An array of Memo objects that are published to update the UI when changes occur.
    @Published var memos: [Memo] = []

    /// The memoRepository property is an instance of MemoRepository, which is used to manage the memos in the application. It provides functions to add and update memos in the memoRepository.
    let memoRepository: MemoRepository
    /// The userDefaultsRepository property is an instance of UserDefaultsRepository, which is used to manage the UserDefaults in the application. It provides functions in the userDefaultsRepository.
    let userDefaultsRepository: UserDefaultsRepository

    init(
        memoRepository: MemoRepository,
        userDefaultsRepository: UserDefaultsRepository
    ) {
        self.memoRepository = memoRepository
        self.userDefaultsRepository = userDefaultsRepository
        fetchMemos()
    }

    /// The model context used for performing SwiftData operations, accessed from the memoRepository.
    var modelContext: ModelContext {
        memoRepository.modelContext
    }

    /// Fetches memos from the memoRepository and updates the published memos array.
    func fetchMemos() {
        self.memos = memoRepository.memos()
    }

    /// Deletes the specified memos from the memoRepository and refreshes the memos list, and renumbers the order of memos in the memoRepository and refreshes the memos list. If an error occurs during the deletion, it throws an error.
    /// - Parameter memos: An array of Memo objects to be deleted.
    func delete(_ memos: [Memo]) throws {
        try memoRepository.delete(memos)
        try memoRepository.renumberOrder()
    }

    /// Moves memos from the specified source indices to the destination index in the memoRepository, and refreshes the memos list after a short delay to ensure the changes are reflected in the UI. If an error occurs during the moving, it throws an error.
    /// - Parameters:
    ///   - source: An integer array representing the indices of the memo to be moved.
    ///   - destination: An integer representing the index to which the memos should be moved.
    func moveMemo(from source: [Int], to destination: Int) throws {
        try memoRepository.moveMemo(from: source, to: destination)
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
}
