//
//  PreviewMemoViewModel.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/07.
//

internal import Combine
import SwiftData

/// PreviewMemoViewModel is responsible for handling the logic related to preview memos.
///
/// It interacts with the UserDefaultsRepository to perform these operations.
final class PreviewMemoViewModel: ObservableObject {
    /// The userDefaultsRepository property is an instance of UserDefaultsRepository, which is used to manage the UserDefaults in the application.
    ///
    /// It provides functions in the userDefaultsRepository.
    private let userDefaultsRepository: UserDefaultsRepository

    init(
        userDefaultsRepository: UserDefaultsRepository
    ) {
        self.userDefaultsRepository = userDefaultsRepository
    }

    private func value<T>(_ getter: (UserDefaultsRepository) -> () -> T) -> T {
        getter(userDefaultsRepository)()
    }

    func getContentFontSize() -> Float {
        value(UserDefaultsRepository.getContentFontSize)
    }

    func getContentLineSpacing() -> Float {
        value(UserDefaultsRepository.getContentLineSpacing)
    }
}
