//
//  PreviewMemoViewModel.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/07.
//

import SwiftData
internal import Combine

/// PreviewMemoViewModel is responsible for handling the logic related to preview memos. It interacts with the UserDefaultsRepository to perform these operations.
class PreviewMemoViewModel: ObservableObject {
    /// The userDefaultsRepository property is an instance of UserDefaultsRepository, which is used to manage the UserDefaults in the application. It provides functions in the userDefaultsRepository.
    private let userDefaultsRepository: UserDefaultsRepository

    init(
        userDefaultsRepository: UserDefaultsRepository
    ) {
        self.userDefaultsRepository = userDefaultsRepository
    }

    func getContentFontSize() -> Float {
        userDefaultsRepository.getContentFontSize()
    }

    func getContentLineSpacing() -> Float {
        userDefaultsRepository.getContentLineSpacing()
    }
}
