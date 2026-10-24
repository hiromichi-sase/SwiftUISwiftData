//
//  BrowseMemoViewModel.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/04.
//

internal import Combine
import SwiftData

/// BrowseMemoViewModel is an observable object that manages the state and interactions for the ContentView, including fetching, deleting, renumbering, and moving memos using the MemoRepository.
final class BrowseMemoViewModel: ObservableObject {
    /// The userDefaultsRepository property is an instance of UserDefaultsRepository, which is used to manage the UserDefaults in the application.
    ///
    /// It provides functions in the userDefaultsRepository.
    private let userDefaultsRepository: UserDefaultsRepository

    init(userDefaultsRepository: UserDefaultsRepository) {
        self.userDefaultsRepository = userDefaultsRepository
    }

    private func value<T>(_ getter: (UserDefaultsRepository) -> () -> T) -> T {
        getter(userDefaultsRepository)()
    }

    func getHasLink() -> Bool {
        value(UserDefaultsRepository.getHasLink)
    }

    func getContentFontSize() -> Float {
        value(UserDefaultsRepository.getContentFontSize)
    }

    func getContentLineSpacing() -> Float {
        value(UserDefaultsRepository.getContentLineSpacing)
    }

    func getShowInfo() -> Bool {
        value(UserDefaultsRepository.getShowInfo)
    }
}
