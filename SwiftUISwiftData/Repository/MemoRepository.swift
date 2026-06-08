//
//  MemoRepository.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/04.
//

import Foundation
import SwiftData

/// MemoRepository is responsible for managing the CRUD operations for Memo entities, including fetching, adding, updating, deleting, and reordering memos in the SwiftData model context.
final class MemoRepository {

    /// The model context used for performing SwiftData operations, accessed from the model container.
    var modelContext: ModelContext
    /// The model container that holds the data model for the application, allowing access to the main context for performing data operations.
    private var modelContainer: ModelContainer
    /// A fetch descriptor that defines how to fetch Memo entities from the model context, sorted by the 'order' property to maintain the correct sequence of memos.
    private let descriptor = FetchDescriptor<Memo>(sortBy: [SortDescriptor(\.order)])

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        modelContext = modelContainer.mainContext
    }

    /// Fetches the list of memos from the model context using the defined fetch descriptor. If an error occurs during fetching, it returns an empty array.
    /// - Returns: An array of Memo objects fetched from the model context, sorted by their order.
    func memos() -> [Memo] {
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            return []
        }
    }

    /// Adds a new memo to the model context. This function sets the createdAt and updatedAt timestamps, assigns an order based on the current count of memos, and then saves the context. If an error occurs during saving, it throws an error.
    /// - Parameter memo: The Memo object that needs to be added to the model context.
    func add(_ memo: Memo) throws {
        let now = Date()
        memo.createdAt = now
        memo.updatedAt = now
        memo.order = memos().count + 1
        modelContext.insert(memo)
        try modelContext.save()
    }

    /// Updates an existing memo in the model context. This function updates the updatedAt timestamp of the memo and then saves the context. If an error occurs during saving, it throws an error.
    /// - Parameter memo: The Memo object that needs to be updated in the model context.
    func update(_ memo: Memo) throws {
        memo.updatedAt = Date()
        try modelContext.save()
    }

    /// Deletes the specified memos from the model context and saves the context. This function iterates through the array of memos to be deleted, removes them from the context, and then saves the changes.  If an error occurs during saving, it throws an error.
    /// - Parameter memos: An array of Memo objects that need to be deleted from the model context.
    func delete(_ memos: [Memo]) throws {
        for memo in memos {
            modelContext.delete(memo)
        }

        try modelContext.save()
    }

    /// Moves memos from the specified source indices to the destination index in the model context. This function first fetches the current list of memos, sorts them by their order, and then moves the memos based on the provided source and destination indices. After reordering, it updates the order property of each memo to reflect their new positions and saves the context.  If an error occurs during saving, it throws an error.
    /// - Parameters:
    ///   - source: An integer array representing the indices of the memos to be moved from their current positions.
    ///   - destination: An integer representing the index to which the memos should be moved in the list.
    func moveMemo(from source: [Int], to destination: Int) throws {
        let memos = self.memos()
        var orderedMemos = memos.sorted(by: { $0.order < $1.order })
        orderedMemos.move(from: source, to: destination)

        for (index, memo) in orderedMemos.enumerated() {
            if let existingMemo = memos.first(where: { $0.id == memo.id }) {
                existingMemo.order = index + 1
            }
        }

        try modelContext.save()
    }

    /// Renumbers the order of memos in the model context. This function iterates through the list of memos, sorted by their current order, and updates the order property of each memo to reflect their new positions based on their index in the sorted list. After updating the order, it saves the context.  If an error occurs during saving, it throws an error.
    func renumberOrder() throws {
        for (index, memo) in memos().enumerated() {
            memo.order = index + 1
        }

        try modelContext.save()
    }
}
