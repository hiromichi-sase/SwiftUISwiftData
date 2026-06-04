//
//  Untitled.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/04.
//

import SwiftData
internal import Combine

/// ContentViewModel is an observable object that manages the state and interactions for the ContentView, including fetching, deleting, renumbering, and moving memos using the MemoRepository.
class ContentViewModel: ObservableObject {
    /// An array of Memo objects that are published to update the UI when changes occur.
    @Published var memos: [Memo] = []

    /// The repository property is an instance of MemoRepository, which is used to manage the memos in the application. It provides functions to add and update memos in the repository.
    private let repository: MemoRepository
    
    init(repository: MemoRepository) {
        self.repository = repository
        fetchMemos()
    }
    
    /// The model context used for performing SwiftData operations, accessed from the repository.
    var modelContext: ModelContext {
        repository.modelContext
    }
    
    /// Fetches memos from the repository and updates the published memos array.
    func fetchMemos() {
        self.memos = repository.memos()
    }
    
    /// Deletes the specified memos from the repository and refreshes the memos list. If an error occurs during the deletion, it throws an error.
    /// - Parameter memos: An array of Memo objects to be deleted.
    func delete(_ memos: [Memo]) throws {
        try repository.delete(memos)
        fetchMemos()
    }
    
    /// Renumbers the order of memos in the repository and refreshes the memos list. If an error occurs during the renumbering, it throws an error.
    func renumberOrder() throws {
        try repository.renumberOrder()
        fetchMemos()
    }
    
    /// Moves memos from the specified source indices to the destination index in the repository, and refreshes the memos list after a short delay to ensure the changes are reflected in the UI. If an error occurs during the moving, it throws an error.
    /// - Parameters:
    ///   - source: An integer array representing the indices of the memo to be moved.
    ///   - destination: An integer representing the index to which the memos should be moved.
    func moveMemo(from source: [Int], to destination: Int) throws {
        try repository.moveMemo(from: source, to: destination)
        fetchMemos()
    }
}
