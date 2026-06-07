//
//  SettingsViewModel.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/07.
//

import SwiftData
internal import Combine

/// SettingsViewModel is an observable object that manages the state and interactions for the SettingsView, including setting values in the UserDefaultRepository.
class SettingsViewModel: ObservableObject {

    /// The userDefaultsRepository property is an instance of UserDefaultsRepository, which is used to manage the UserDefaults in the application. It provides functions in the userDefaultsRepository.
    private let userDefaultsRepository: UserDefaultsRepository

    init(
        userDefaultsRepository: UserDefaultsRepository
    ) {
        self.userDefaultsRepository = userDefaultsRepository
    }

    func getHasLink() -> Bool {
        userDefaultsRepository.getHasLink()
    }

    func setHasLink(_ value: Bool) {
        userDefaultsRepository.setHasLink(value)
    }

    func getContentFontSize() -> Float {
        userDefaultsRepository.getContentFontSize()
    }

    func setContentFontSize(_ value: Float) {
        userDefaultsRepository.setContentFontSize(value)
    }

    func getContentLineSpacing() -> Float {
        userDefaultsRepository.getContentLineSpacing()
    }

    func setContentLineSpacing(_ value: Float) {
        userDefaultsRepository.setContentLineSpacing(value)
    }

    func getTitleLineLimit() -> Int {
        userDefaultsRepository.getTitleLineLimit()
    }

    func setTitleLineLimit(_ value: Int) {
        userDefaultsRepository.setTitleLineLimit(value)
    }

}
