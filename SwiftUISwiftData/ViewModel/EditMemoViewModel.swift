//
//  EditMemoViewModel.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/04.
//

import SwiftData
internal import Combine

/// EditMemoViewModel is responsible for handling the logic related to adding and updating memos. It interacts with the MemoRepository to perform these operations.
class EditMemoViewModel: ObservableObject {
    /// The repository property is an instance of MemoRepository, which is used to manage the memos in the application. It provides functions to add and update memos in the repository.
    let repository: MemoRepository

    init(repository: MemoRepository) {
        self.repository = repository
    }

    /// Adds a new memo to the repository. This function takes a Memo object as a parameter and attempts to add it to the repository. If an error occurs during the addition, it throws an error.
    /// - Parameter memo: The Memo object that needs to be added to the repository.
    func add(_ memo: Memo) throws {
        try repository.add(memo)
    }

    /// Updates an existing memo in the repository. This function takes a Memo object as a parameter and attempts to update it in the repository. If an error occurs during the update, it throws an error.
    /// - Parameter memo: The Memo object that needs to be updated in the repository.
    func update(_ memo: Memo) throws {
        try repository.update(memo)
    }
}
