//
//  SettingsViewModelTests.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/08.
//

import Testing

@testable import SwiftUISwiftData

struct SettingsViewModelTests {
    @MainActor
    @Test
    func hasLink() {
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        let defaultValue: Bool = true
        let changed = dependency.testTarget.hasLinkChanged(defaultValue)
        #expect(!changed)

        dependency.testTarget.setHasLink(defaultValue)
        #expect(dependency.testTarget.getHasLink() == defaultValue)
    }

    @MainActor
    @Test
    func contentFontSize() {
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        let defaultValue: Float = 16.0
        let changed = dependency.testTarget.contentFontSizeChanged(defaultValue)
        #expect(!changed)

        dependency.testTarget.setContentFontSize(defaultValue)
        #expect(dependency.testTarget.getContentFontSize() == defaultValue)

        let lowerBound: Float = 5.0
        let upperBound: Float = 100.0
        #expect(dependency.testTarget.contentFontSizeRange == lowerBound ... upperBound)
    }

    @MainActor
    @Test
    func contentLineSpacing() {
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        let defaultValue: Float = .zero
        let changed = dependency.testTarget.contentLineSpacingChanged(defaultValue)
        #expect(!changed)

        dependency.testTarget.setContentLineSpacing(defaultValue)
        #expect(dependency.testTarget.getContentLineSpacing() == defaultValue)

        let lowerBound: Float = .zero
        let upperBound: Float = 10.0
        #expect(dependency.testTarget.contentLineSpacingRange == lowerBound ... upperBound)
    }

    @MainActor
    @Test
    func titleLineLimit() {
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        let defaultValue: Int = 3
        let changed = dependency.testTarget.titleLineLimitChanged(defaultValue)
        #expect(!changed)

        dependency.testTarget.setTitleLineLimit(defaultValue)
        #expect(dependency.testTarget.getTitleLineLimit() == defaultValue)

        let lowerBound: Int = 1
        let upperBound: Int = 5
        #expect(dependency.testTarget.titleLineLimitRange == lowerBound ... upperBound)
    }

    @MainActor
    @Test
    func titleFontSize() {
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        let defaultValue: Float = 16.0
        let changed = dependency.testTarget.titleFontSizeChanged(defaultValue)
        #expect(!changed)

        dependency.testTarget.setTitleFontSize(defaultValue)
        #expect(dependency.testTarget.getTitleFontSize() == defaultValue)

        let lowerBound: Float = 5.0
        let upperBound: Float = 100.0
        #expect(dependency.testTarget.titleFontSizeRange == lowerBound ... upperBound)
    }

    @MainActor
    @Test
    func titleLineSpacing() {
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        let defaultValue: Float = .zero
        let changed = dependency.testTarget.titleLineSpacingChanged(defaultValue)
        #expect(!changed)

        dependency.testTarget.setTitleLineSpacing(defaultValue)
        #expect(dependency.testTarget.getTitleLineSpacing() == defaultValue)

        let lowerBound: Float = .zero
        let upperBound: Float = 10.0
        #expect(dependency.testTarget.titleLineSpacingRange == lowerBound ... upperBound)
    }

    @MainActor
    @Test
    func showInfo() {
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        let defaultValue: Bool = false
        let changed = dependency.testTarget.showInfoChanged(defaultValue)
        #expect(!changed)

        dependency.testTarget.setShowInfo(defaultValue)
        #expect(dependency.testTarget.getShowInfo() == defaultValue)
    }

    @MainActor
    @Test
    func defaultTagColor() {
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        let defaultValue: String = "#000000"
        let changed = dependency.testTarget.defaultTagColorChanged(defaultValue)
        #expect(!changed)

        dependency.testTarget.setDefaultTagColor(defaultValue)
        #expect(dependency.testTarget.getDefaultTagColor() == defaultValue)
    }

    @MainActor
    @Test
    func reset_restoresAllDefaults() {
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.testTarget.setHasLink(false)
        dependency.testTarget.setContentFontSize(30.0)
        dependency.testTarget.setContentLineSpacing(5.0)
        dependency.testTarget.setTitleLineLimit(5)
        dependency.testTarget.setTitleFontSize(30.0)
        dependency.testTarget.setTitleLineSpacing(5.0)
        dependency.testTarget.setShowInfo(true)
        dependency.testTarget.setDefaultTagColor("#FF0000")
        #expect(dependency.testTarget.settingsChanged)

        dependency.testTarget.reset()

        #expect(dependency.testTarget.getHasLink() == true)
        #expect(dependency.testTarget.getContentFontSize() == Float(16.0))
        #expect(dependency.testTarget.getContentLineSpacing() == Float.zero)
        #expect(dependency.testTarget.getTitleLineLimit() == 3)
        #expect(dependency.testTarget.getTitleFontSize() == Float(16.0))
        #expect(dependency.testTarget.getTitleLineSpacing() == Float.zero)
        #expect(dependency.testTarget.getShowInfo() == false)
        #expect(dependency.testTarget.getDefaultTagColor() == "#000000")
        #expect(!dependency.testTarget.settingsChanged)
    }

    @MainActor
    @Test
    func canSave_changesForEachSetting() {
        typealias Snapshot = SettingsViewModel.SettingsSnapshot

        let changes: [(name: String, update: (inout Snapshot) -> Void)] = [
            ("hasLink", { $0.hasLink = false }),
            ("contentFontSize", { $0.contentFontSize = 20.0 }),
            ("contentLineSpacing", { $0.contentLineSpacing = 2.0 }),
            ("titleLineLimit", { $0.titleLineLimit = 5 }),
            ("titleFontSize", { $0.titleFontSize = 24.0 }),
            ("titleLineSpacing", { $0.titleLineSpacing = 3.0 }),
            ("showInfo", { $0.showInfo = true }),
            ("defaultTagColor", { $0.defaultTagColor = "#FF0000" }),
        ]

        for change in changes {
            let support = TestDependencySupport()
            defer { support.removeUserDefaults() }

            let viewModel = SettingsViewModel(
                userDefaultsRepository: support.userDefaultsRepository,
                suiteName: support.suiteName
            )
            let original = viewModel.draft

            #expect(!viewModel.canSave, "Initial state: \(change.name)")

            var edited = original
            change.update(&edited)
            viewModel.draft = edited

            #expect(viewModel.canSave, "After editing: \(change.name)")
            #expect(viewModel.savedSettings == original, "Saved state: \(change.name)")

            // 編集しただけでは永続化されない。
            let beforeSave = SettingsViewModel.SettingsSnapshot(
                repository: support.userDefaultsRepository
            )
            #expect(beforeSave == original, "Before save: \(change.name)")

            // 元に戻した場合は保存不要。
            viewModel.draft = original
            #expect(!viewModel.canSave, "After reverting: \(change.name)")

            // 保存後は、新しい値が比較基準になる。
            viewModel.draft = edited
            viewModel.save()

            #expect(!viewModel.canSave, "After saving: \(change.name)")
            #expect(viewModel.savedSettings == edited, "Saved value: \(change.name)")

            // 保存前の値に戻すと、再び保存可能になる。
            viewModel.draft = original
            #expect(viewModel.canSave, "After changing back: \(change.name)")

            viewModel.draft = edited
            #expect(!viewModel.canSave, "After restoring saved value: \(change.name)")
        }
    }

    /// 全設定の永続化と、保存後の状態更新を確認する。
    @MainActor
    @Test
    func save_persistsAllSettingsAndUpdatesSavedState() {
        let support = TestDependencySupport()
        defer { support.removeUserDefaults() }

        let repository = support.userDefaultsRepository
        let viewModel = SettingsViewModel(
            userDefaultsRepository: repository,
            suiteName: support.suiteName
        )

        viewModel.draft.hasLink = false
        viewModel.draft.contentFontSize = 20.0
        viewModel.draft.contentLineSpacing = 2.0
        viewModel.draft.titleLineLimit = 5
        viewModel.draft.titleFontSize = 24.0
        viewModel.draft.titleLineSpacing = 3.0
        viewModel.draft.showInfo = true
        viewModel.draft.defaultTagColor = "#FF0000"

        let expected = viewModel.draft
        #expect(viewModel.canSave)

        viewModel.save()

        #expect(repository.getHasLink() == false)
        #expect(repository.getContentFontSize() == 20.0)
        #expect(repository.getContentLineSpacing() == 2.0)
        #expect(repository.getTitleLineLimit() == 5)
        #expect(repository.getTitleFontSize() == 24.0)
        #expect(repository.getTitleLineSpacing() == 3.0)
        #expect(repository.getShowInfo() == true)
        #expect(repository.getDefaultTagColor() == "#FF0000")

        #expect(viewModel.draft == expected)
        #expect(viewModel.savedSettings == expected)
        #expect(!viewModel.canSave)

        // 新しい ViewModel でも保存済みの値を読み込める。
        let reloaded = SettingsViewModel(
            userDefaultsRepository: repository,
            suiteName: support.suiteName
        )
        #expect(reloaded.draft == expected)
        #expect(reloaded.savedSettings == expected)
        #expect(!reloaded.canSave)

        // 変更がない状態で再保存しても値は変わらない。
        viewModel.save()
        #expect(viewModel.draft == expected)
        #expect(viewModel.savedSettings == expected)
        #expect(!viewModel.canSave)

        // 保存後の追加変更も保存できる。
        viewModel.draft.contentFontSize = 30.0
        #expect(viewModel.canSave)

        viewModel.save()

        #expect(repository.getContentFontSize() == 30.0)
        #expect(repository.getDefaultTagColor() == "#FF0000")
        #expect(viewModel.savedSettings == viewModel.draft)
        #expect(!viewModel.canSave)
    }
}

extension SettingsViewModelTests {
    struct Dependency {
        let testTarget: SettingsViewModel
        private let support: TestDependencySupport

        @MainActor
        init() {
            let support = TestDependencySupport()
            self.support = support
            testTarget = .init(
                userDefaultsRepository: support.userDefaultsRepository,
                suiteName: support.suiteName
            )
        }

        func removeUserDefaults() {
            support.removeUserDefaults()
        }
    }
}
