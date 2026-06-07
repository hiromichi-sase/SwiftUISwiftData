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
    }

    /// Adds a new memo to the memoRepository. This function takes a Memo object as a parameter and attempts to add it to the memoRepository. If an error occurs during the addition, it throws an error.
    /// - Parameter memo: The Memo object that needs to be added to the memoRepository.
    func add(_ memo: Memo) throws {
        try memoRepository.add(memo)
    }

    /// Updates an existing memo in the memoRepository. This function takes a Memo object as a parameter and attempts to update it in the memoRepository. If an error occurs during the update, it throws an error.
    /// - Parameter memo: The Memo object that needs to be updated in the memoRepository.
    func update(_ memo: Memo) throws {
        try memoRepository.update(memo)
    }

    func getContentFontSize() -> Float {
        userDefaultsRepository.getContentFontSize()
    }

    func getContentLineSpacing() -> Float {
        userDefaultsRepository.getContentLineSpacing()
    }
}
