//
//  SettingsViewModel.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/07.
//

import Observation

@Observable
@MainActor
final class SettingsViewModel {
    /// 設定値のスナップショット。
    struct SettingsSnapshot: Equatable {
        var hasLink: Bool
        var contentFontSize: Float
        var contentLineSpacing: Float
        var titleLineLimit: Int
        var titleFontSize: Float
        var titleLineSpacing: Float
        var showInfo: Bool
        var defaultTagColor: String

        init(repository: UserDefaultsRepository) {
            hasLink = repository.getHasLink()
            contentFontSize = repository.getContentFontSize()
            contentLineSpacing = repository.getContentLineSpacing()
            titleLineLimit = repository.getTitleLineLimit()
            titleFontSize = repository.getTitleFontSize()
            titleLineSpacing = repository.getTitleLineSpacing()
            showInfo = repository.getShowInfo()
            defaultTagColor = repository.getDefaultTagColor()
        }
    }

    private let userDefaultsRepository: UserDefaultsRepository
    private let suiteName: String?

    /// 画面で編集中の設定値。
    var draft: SettingsSnapshot

    /// 最後に読み込んだ、または保存した設定値。
    private(set) var savedSettings: SettingsSnapshot

    init(
        userDefaultsRepository: UserDefaultsRepository,
        suiteName: String? = nil
    ) {
        self.userDefaultsRepository = userDefaultsRepository
        self.suiteName = suiteName

        let snapshot = SettingsSnapshot(repository: userDefaultsRepository)
        draft = snapshot
        savedSettings = snapshot
    }

    // MARK: - Ranges

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

    // MARK: - Derived State

    /// 編集値が保存済み値と異なる場合に保存できる。
    var canSave: Bool {
        draft != savedSettings
    }

    /// 保存済みの設定がデフォルト値から変更されているか。
    ///
    /// Reset ボタンの有効状態は、従来どおり編集値ではなく
    /// 保存済みの設定値を基準とする。
    var settingsChanged: Bool {
        hasLinkChanged(savedSettings.hasLink)
            || contentFontSizeChanged(savedSettings.contentFontSize)
            || contentLineSpacingChanged(savedSettings.contentLineSpacing)
            || titleLineLimitChanged(savedSettings.titleLineLimit)
            || titleFontSizeChanged(savedSettings.titleFontSize)
            || titleLineSpacingChanged(savedSettings.titleLineSpacing)
            || showInfoChanged(savedSettings.showInfo)
            || defaultTagColorChanged(savedSettings.defaultTagColor)
    }

    // MARK: - Actions

    /// 編集中の設定を保存する。
    func save() {
        let settings = draft

        userDefaultsRepository.setHasLink(settings.hasLink)
        userDefaultsRepository.setContentFontSize(settings.contentFontSize)
        userDefaultsRepository.setContentLineSpacing(settings.contentLineSpacing)
        userDefaultsRepository.setTitleLineLimit(settings.titleLineLimit)
        userDefaultsRepository.setTitleFontSize(settings.titleFontSize)
        userDefaultsRepository.setTitleLineSpacing(settings.titleLineSpacing)
        userDefaultsRepository.setShowInfo(settings.showInfo)
        userDefaultsRepository.setDefaultTagColor(settings.defaultTagColor)

        reloadSettings()
    }

    /// 保存済みの設定をリセットし、編集値も更新する。
    func reset() {
        userDefaultsRepository.reset(suiteName: suiteName)
        reloadSettings()
    }

    private func reloadSettings() {
        let snapshot = SettingsSnapshot(repository: userDefaultsRepository)
        draft = snapshot
        savedSettings = snapshot
    }

    // MARK: - Default Value Comparisons

    func hasLinkChanged(_ value: Bool) -> Bool {
        userDefaultsRepository.hasLinkChanged(value)
    }

    func contentFontSizeChanged(_ value: Float) -> Bool {
        userDefaultsRepository.contentFontSizeChanged(value)
    }

    func contentLineSpacingChanged(_ value: Float) -> Bool {
        userDefaultsRepository.contentLineSpacingChanged(value)
    }

    func titleLineLimitChanged(_ value: Int) -> Bool {
        userDefaultsRepository.titleLineLimitChanged(value)
    }

    func titleFontSizeChanged(_ value: Float) -> Bool {
        userDefaultsRepository.titleFontSizeChanged(value)
    }

    func titleLineSpacingChanged(_ value: Float) -> Bool {
        userDefaultsRepository.titleLineSpacingChanged(value)
    }

    func showInfoChanged(_ value: Bool) -> Bool {
        userDefaultsRepository.showInfoChanged(value)
    }

    func defaultTagColorChanged(_ value: String) -> Bool {
        userDefaultsRepository.showDefaultTagColorChanged(value)
    }

    // MARK: - Existing API Compatibility

    // 既存のテストとの互換性のために残す。
    // 画面からの編集は draft と save() を使用する。

    func getHasLink() -> Bool {
        userDefaultsRepository.getHasLink()
    }

    func setHasLink(_ value: Bool) {
        userDefaultsRepository.setHasLink(value)
        reloadSettings()
    }

    func getContentFontSize() -> Float {
        userDefaultsRepository.getContentFontSize()
    }

    func setContentFontSize(_ value: Float) {
        userDefaultsRepository.setContentFontSize(value)
        reloadSettings()
    }

    func getContentLineSpacing() -> Float {
        userDefaultsRepository.getContentLineSpacing()
    }

    func setContentLineSpacing(_ value: Float) {
        userDefaultsRepository.setContentLineSpacing(value)
        reloadSettings()
    }

    func getTitleLineLimit() -> Int {
        userDefaultsRepository.getTitleLineLimit()
    }

    func setTitleLineLimit(_ value: Int) {
        userDefaultsRepository.setTitleLineLimit(value)
        reloadSettings()
    }

    func getTitleFontSize() -> Float {
        userDefaultsRepository.getTitleFontSize()
    }

    func setTitleFontSize(_ value: Float) {
        userDefaultsRepository.setTitleFontSize(value)
        reloadSettings()
    }

    func getTitleLineSpacing() -> Float {
        userDefaultsRepository.getTitleLineSpacing()
    }

    func setTitleLineSpacing(_ value: Float) {
        userDefaultsRepository.setTitleLineSpacing(value)
        reloadSettings()
    }

    func getShowInfo() -> Bool {
        userDefaultsRepository.getShowInfo()
    }

    func setShowInfo(_ value: Bool) {
        userDefaultsRepository.setShowInfo(value)
        reloadSettings()
    }

    func getDefaultTagColor() -> String {
        userDefaultsRepository.getDefaultTagColor()
    }

    func setDefaultTagColor(_ value: String) {
        userDefaultsRepository.setDefaultTagColor(value)
        reloadSettings()
    }
}
