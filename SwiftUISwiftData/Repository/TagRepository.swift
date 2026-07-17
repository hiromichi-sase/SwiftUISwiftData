//
//  TagRepository.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import Foundation
import SwiftData

/// TagRepository is responsible for managing the CRUD operations for Tag entities, including fetching, adding, updating, deleting, and reordering tags in the SwiftData model context.
final class TagRepository {
    /// The model context used for performing SwiftData operations, accessed from the model container.
    private(set) var modelContext: ModelContext
    /// The model container that holds the data model for the application, allowing access to the main context for performing data operations.
    private var modelContainer: ModelContainer
    /// A fetch descriptor that defines how to fetch Tag entities from the model context, sorted by the 'order' property to maintain the correct sequence of tags.
    private let descriptor = FetchDescriptor<Tag>(sortBy: [SortDescriptor(\.order)])

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        modelContext = modelContainer.mainContext
    }

    /// Fetches the list of tags from the model context using the defined fetch descriptor.
    ///
    /// If an error occurs during fetching, it returns an empty array.
    /// - Returns: An array of Tag objects fetched from the model context, sorted by their order.
    func tags() -> [Tag] {
        do {
            return try modelContext.fetch(descriptor)
        }
        catch {
            return []
        }
    }

    /// Adds a new tag to the model context.
    ///
    /// This function sets the createdAt and updatedAt timestamps, assigns an order based on the current count of tags, and then saves the context. If an error occurs during saving, it throws an error.
    /// - Parameter tag: The Tag object that needs to be added to the model context.
    /// - throws: An error.
    func add(_ tag: Tag) throws {
        try modelContext.transaction {
            let now = Date()
            tag.createdAt = now
            tag.updatedAt = now
            tag.order = tags().count + 1
            modelContext.insert(tag)
            reorder()
        }
    }

    /// Updates an existing tag in the model context.
    ///
    /// This function updates the updatedAt timestamp of the tag and then saves the context. If an error occurs during saving, it throws an error.
    /// - Parameters:
    ///   - tag: The Tag object that needs to be updated in the model context.
    ///   - title: The title that needs to be updated.
    ///   - color: The color that needs to be updated.
    /// - throws: An error.
    func update(_ tag: Tag, title: String, color: String) throws {
        try modelContext.transaction {
            tag.title = title
            tag.color = color
            tag.updatedAt = Date()
        }
    }

    /// Deletes the specified tags from the model context.
    ///
    /// This function iterates through the array of tags to be deleted, removes them from the context, and renumbers the order of tags in the model context. ant then iterates through the list of tags, sorted by their current order, and updates the order property of each tag to reflect their new positions based on their index in the sorted list. After updating the order, it saves the context. If an error occurs during saving, it throws an error.
    /// - Parameter tags: An array of Tag objects that need to be deleted from the model context.
    /// - throws: An error.
    func delete(_ tags: [Tag]) throws {
        try modelContext.transaction {
            for tag in tags {
                modelContext.delete(tag)
            }
            reorder()
        }
    }

    /// Moves tags from the specified source indices to the destination index in the model context.
    ///
    /// This function first fetches the current list of tags, sorts them by their order, and then moves the tags based on the provided source and destination indices. After reordering, it updates the order property of each tag to reflect their new positions and saves the context.  If an error occurs during saving, it throws an error.
    /// - Parameters:
    ///   - source: An integer array representing the indices of the tags to be moved from their current positions.
    ///   - destination: An integer representing the index to which the tags should be moved in the list.
    /// - throws: An error.
    func moveTag(from source: [Int], to destination: Int) throws {
        try modelContext.transaction {
            let tags = tags()
            var orderedTags = tags.sortedByOrder
            orderedTags.move(from: source, to: destination)

            for (index, tag) in orderedTags.enumerated() {
                if let existingTag = tags.first(where: { $0.id == tag.id }) {
                    existingTag.order = index + 1
                }
            }
        }
    }

    /// Reorder all tags in the model context.
    private func reorder() {
        for (index, tag) in tags().enumerated() {
            tag.order = index + 1
        }
    }
}
