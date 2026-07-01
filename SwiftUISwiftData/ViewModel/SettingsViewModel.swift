//
//  SettingsViewModel.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/07.
//

internal import Combine
import SwiftData

/// SettingsViewModel is an observable object that manages the state and interactions for the SettingsView, including setting values in the UserDefaultRepository.
final class SettingsViewModel: ObservableObject {
    /// The userDefaultsRepository property is an instance of UserDefaultsRepository, which is used to manage the UserDefaults in the application.
    ///
    /// It provides functions in the userDefaultsRepository.
    private let userDefaultsRepository: UserDefaultsRepository
    private let suiteName: String?

    init(
        userDefaultsRepository: UserDefaultsRepository,
        suiteName: String? = nil
    ) {
        self.userDefaultsRepository = userDefaultsRepository
        self.suiteName = suiteName
    }

    var settingsChanged: Bool {
        userDefaultsRepository.settingsChanged
    }

    var contentFontSizeRange: ClosedRange<Float> {
        userDefaultsRepository.contentFontSizeRange
    }

    var contentLineSpacingRange: ClosedRange<Float> {
        userDefaultsRepository.contentLineSpacingRange
    }

    var titleLineLimitRange: ClosedRange<Int> {
        userDefaultsRepository.titleLineLimitRange
    }

    var titleFontSizeRange: ClosedRange<Float> {
        userDefaultsRepository.titleFontSizeRange
    }

    var titleLineSpacingRange: ClosedRange<Float> {
        userDefaultsRepository.titleLineSpacingRange
    }

    func reset() {
        userDefaultsRepository.reset(suiteName: suiteName)
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

    func getTitleFontSize() -> Float {
        userDefaultsRepository.getTitleFontSize()
    }

    func setTitleFontSize(_ value: Float) {
        userDefaultsRepository.setTitleFontSize(value)
    }

    func getTitleLineSpacing() -> Float {
        userDefaultsRepository.getTitleLineSpacing()
    }

    func setTitleLineSpacing(_ value: Float) {
        userDefaultsRepository.setTitleLineSpacing(value)
    }

    func getShowInfo() -> Bool {
        userDefaultsRepository.getShowInfo()
    }

    func setShowInfo(_ value: Bool) {
        userDefaultsRepository.setShowInfo(value)
    }

    func getDivideKeywordsBySpace() -> Bool {
        userDefaultsRepository.getDivideKeywordsBySpace()
    }

    func setDivideKeywordsBySpace(_ value: Bool) {
        userDefaultsRepository.setDivideKeywordsBySpace(value)
    }
}
