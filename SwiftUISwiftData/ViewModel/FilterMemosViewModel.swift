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
    /// An array of Tag objects that are published to update the UI when changes occur.
    private(set) var tags: [Tag] = []

    init(
        tagRepository: TagRepository,
    ) {
        tags = tagRepository.tags()
    }
}
