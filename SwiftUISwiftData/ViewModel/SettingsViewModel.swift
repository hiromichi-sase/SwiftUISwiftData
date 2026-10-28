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

    private func value<T>(_ getter: (UserDefaultsRepository) -> () -> T) -> T {
        getter(userDefaultsRepository)()
    }

    private func setValue<T>(_ value: T, with setter: (UserDefaultsRepository) -> (T) -> Void) {
        setter(userDefaultsRepository)(value)
    }

    private func hasChanged<T>(_ value: T, with checker: (UserDefaultsRepository) -> (T) -> Bool) -> Bool {
        checker(userDefaultsRepository)(value)
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
        value(UserDefaultsRepository.getHasLink)
    }

    func setHasLink(_ value: Bool) {
        setValue(value, with: UserDefaultsRepository.setHasLink)
    }

    func getContentFontSize() -> Float {
        value(UserDefaultsRepository.getContentFontSize)
    }

    func setContentFontSize(_ value: Float) {
        setValue(value, with: UserDefaultsRepository.setContentFontSize)
    }

    func getContentLineSpacing() -> Float {
        value(UserDefaultsRepository.getContentLineSpacing)
    }

    func setContentLineSpacing(_ value: Float) {
        setValue(value, with: UserDefaultsRepository.setContentLineSpacing)
    }

    func getTitleLineLimit() -> Int {
        value(UserDefaultsRepository.getTitleLineLimit)
    }

    func setTitleLineLimit(_ value: Int) {
        setValue(value, with: UserDefaultsRepository.setTitleLineLimit)
    }

    func getTitleFontSize() -> Float {
        value(UserDefaultsRepository.getTitleFontSize)
    }

    func setTitleFontSize(_ value: Float) {
        setValue(value, with: UserDefaultsRepository.setTitleFontSize)
    }

    func getTitleLineSpacing() -> Float {
        value(UserDefaultsRepository.getTitleLineSpacing)
    }

    func setTitleLineSpacing(_ value: Float) {
        setValue(value, with: UserDefaultsRepository.setTitleLineSpacing)
    }

    func getShowInfo() -> Bool {
        value(UserDefaultsRepository.getShowInfo)
    }

    func setShowInfo(_ value: Bool) {
        setValue(value, with: UserDefaultsRepository.setShowInfo)
    }

    func getDefaultTagColor() -> String {
        value(UserDefaultsRepository.getDefaultTagColor)
    }

    func setDefaultTagColor(_ value: String) {
        setValue(value, with: UserDefaultsRepository.setDefaultTagColor)
    }

    func hasLinkChanged(_ hasLink: Bool) -> Bool {
        hasChanged(hasLink, with: UserDefaultsRepository.hasLinkChanged)
    }

    func contentFontSizeChanged(_ contentFontSize: Float) -> Bool {
        hasChanged(contentFontSize, with: UserDefaultsRepository.contentFontSizeChanged)
    }

    func contentLineSpacingChanged(_ contentLineSpacing: Float) -> Bool {
        hasChanged(contentLineSpacing, with: UserDefaultsRepository.contentLineSpacingChanged)
    }

    func titleLineLimitChanged(_ titleLineLimit: Int) -> Bool {
        hasChanged(titleLineLimit, with: UserDefaultsRepository.titleLineLimitChanged)
    }

    func titleFontSizeChanged(_ titleFontSize: Float) -> Bool {
        hasChanged(titleFontSize, with: UserDefaultsRepository.titleFontSizeChanged)
    }

    func titleLineSpacingChanged(_ titleLineSpacing: Float) -> Bool {
        hasChanged(titleLineSpacing, with: UserDefaultsRepository.titleLineSpacingChanged)
    }

    func showInfoChanged(_ showInfo: Bool) -> Bool {
        hasChanged(showInfo, with: UserDefaultsRepository.showInfoChanged)
    }

    func defaultTagColorChanged(_ defaultTagColor: String) -> Bool {
        hasChanged(defaultTagColor, with: UserDefaultsRepository.showDefaultTagColorChanged)
    }
}
