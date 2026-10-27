//
//  SettingsView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/07.
//

import SwiftData
import SwiftUI

/// 設定画面を表示するビュー。
struct SettingsView: View {
    private struct SettingsSnapshot: Equatable {
        var hasLink: Bool
        var contentFontSize: Float
        var contentLineSpacing: Float
        var titleLineLimit: Int
        var titleFontSize: Float
        var titleLineSpacing: Float
        var showInfo: Bool
        var divideKeywordsBySpace: Bool
        var defaultTagColor: String

        init(
            hasLink: Bool,
            contentFontSize: Float,
            contentLineSpacing: Float,
            titleLineLimit: Int,
            titleFontSize: Float,
            titleLineSpacing: Float,
            showInfo: Bool,
            divideKeywordsBySpace: Bool,
            defaultTagColor: String
        ) {
            self.hasLink = hasLink
            self.contentFontSize = contentFontSize
            self.contentLineSpacing = contentLineSpacing
            self.titleLineLimit = titleLineLimit
            self.titleFontSize = titleFontSize
            self.titleLineSpacing = titleLineSpacing
            self.showInfo = showInfo
            self.divideKeywordsBySpace = divideKeywordsBySpace
            self.defaultTagColor = defaultTagColor
        }

        init(viewModel: SettingsViewModel) {
            hasLink = viewModel.getHasLink()
            contentFontSize = viewModel.getContentFontSize()
            contentLineSpacing = viewModel.getContentLineSpacing()
            titleLineLimit = viewModel.getTitleLineLimit()
            titleFontSize = viewModel.getTitleFontSize()
            titleLineSpacing = viewModel.getTitleLineSpacing()
            showInfo = viewModel.getShowInfo()
            divideKeywordsBySpace = viewModel.getDivideKeywordsBySpace()
            defaultTagColor = viewModel.getDefaultTagColor()
        }
    }

    /// ビューの状態を管理するViewModel。
    @ObservedObject
    var viewModel = SettingsViewModel(
        userDefaultsRepository: UserDefaultsRepository()
    )
    @State
    private var hasLink: Bool = false
    @State
    private var contentFontSize: Float = .zero
    @State
    private var contentLineSpacing: Float = .zero
    @State
    private var titleLineLimit: Int = .zero
    @State
    private var titleFontSize: Float = .zero
    @State
    private var titleLineSpacing: Float = .zero
    @State
    private var showInfo: Bool = false
    @State
    private var divideKeywordsBySpace: Bool = false
    @State
    private var defaultTagColor: String = ""

    @State
    private var hasLinkToStore: Bool = false
    @State
    private var contentFontSizeToStore: Float = .zero
    @State
    private var contentLineSpacingToStore: Float = .zero
    @State
    private var titleLineLimitToStore: Int = .zero
    @State
    private var titleFontSizeToStore: Float = .zero
    @State
    private var titleLineSpacingToStore: Float = .zero
    @State
    private var showInfoToStore: Bool = false
    @State
    private var divideKeywordsBySpaceToStore: Bool = false
    @State
    private var defaultTagColorToStore: String = ""

    @State
    private var color: Color = .clear

    /// トーストメッセージの状態変数。
    @State
    private var toastMessage = ""
    @State
    private var showResetAlert = false
    /// ビューを閉じるための環境変数。
    @Environment(\.dismiss)
    private var dismiss

    init() {
        let snapshot = SettingsSnapshot(viewModel: viewModel)
        _hasLink = State(initialValue: snapshot.hasLink)
        _contentFontSize = State(initialValue: snapshot.contentFontSize)
        _contentLineSpacing = State(initialValue: snapshot.contentLineSpacing)
        _titleLineLimit = State(initialValue: snapshot.titleLineLimit)
        _titleFontSize = State(initialValue: snapshot.titleFontSize)
        _titleLineSpacing = State(initialValue: snapshot.titleLineSpacing)
        _showInfo = State(initialValue: snapshot.showInfo)
        _divideKeywordsBySpace = State(initialValue: snapshot.divideKeywordsBySpace)
        _defaultTagColor = State(initialValue: snapshot.defaultTagColor)

        _hasLinkToStore = State(initialValue: snapshot.hasLink)
        _contentFontSizeToStore = State(initialValue: snapshot.contentFontSize)
        _contentLineSpacingToStore = State(initialValue: snapshot.contentLineSpacing)
        _titleLineLimitToStore = State(initialValue: snapshot.titleLineLimit)
        _titleFontSizeToStore = State(initialValue: snapshot.titleFontSize)
        _titleLineSpacingToStore = State(initialValue: snapshot.titleLineSpacing)
        _showInfoToStore = State(initialValue: snapshot.showInfo)
        _divideKeywordsBySpaceToStore = State(initialValue: snapshot.divideKeywordsBySpace)
        _defaultTagColorToStore = State(initialValue: snapshot.defaultTagColor)
    }

    var body: some View {
        NavigationStack {
            Form {
                browseSection
                contentSection
                titleSection
                infoSection
                searchSection
                colorSection
            }
            .onLoad {
                color = defaultTagColor.color()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    toolbarItemTopBarTrailing
                }
            }
            .alert(isPresented: $showResetAlert) {
                resetAlert
            }
            .toast(message: $toastMessage)
        }
    }

    private var browseSection: some View {
        Section("Browse") {
            VStack(alignment: .leading) {
                Text("Has Link")
                    .font(.system(size: 12.0))
                Toggle(isOn: $hasLink) {
                    Text(hasLink ? "ON" : "OFF")
                        .fontWeight(viewModel.hasLinkChanged(hasLink) ? .bold : .regular)
                }
            }
        }
    }

    private var contentSection: some View {
        Section("Content") {
            VStack(alignment: .leading) {
                Text("Font Size (\(rangeString(viewModel.contentFontSizeRange)))")
                    .font(.system(size: 12.0))
                Stepper(
                    value: $contentFontSize,
                    in: viewModel.contentFontSizeRange,
                    step: 0.5
                ) {
                    Text("\(contentFontSize, specifier: "%.1f")")
                        .fontWeight(viewModel.contentFontSizeChanged(contentFontSize) ? .bold : .regular)
                }
            }
            VStack(alignment: .leading) {
                Text("Line Spacing (\(rangeString(viewModel.contentLineSpacingRange)))")
                    .font(.system(size: 12.0))
                Stepper(
                    value: $contentLineSpacing,
                    in: viewModel.contentLineSpacingRange,
                    step: 0.5
                ) {
                    Text("\(contentLineSpacing, specifier: "%.1f")")
                        .fontWeight(viewModel.contentLineSpacingChanged(contentLineSpacing) ? .bold : .regular)
                }
            }
        }
    }

    private var titleSection: some View {
        Section("Title") {
            VStack(alignment: .leading) {
                Text("Line Limit (\(rangeString(viewModel.titleLineLimitRange)))")
                    .font(.system(size: 12.0))
                Stepper(
                    value: $titleLineLimit,
                    in: viewModel.titleLineLimitRange,
                ) {
                    Text("\(titleLineLimit)")
                        .fontWeight(viewModel.titleLineLimitChanged(titleLineLimit) ? .bold : .regular)
                }
            }
            VStack(alignment: .leading) {
                Text("Font Size (\(rangeString(viewModel.titleFontSizeRange)))")
                    .font(.system(size: 12.0))
                Stepper(
                    value: $titleFontSize,
                    in: viewModel.titleFontSizeRange,
                    step: 0.5
                ) {
                    Text("\(titleFontSize, specifier: "%.1f")")
                        .fontWeight(viewModel.titleFontSizeChanged(titleFontSize) ? .bold : .regular)
                }
            }
            VStack(alignment: .leading) {
                Text("Line Spacing (\(rangeString(viewModel.titleLineSpacingRange)))")
                    .font(.system(size: 12.0))
                Stepper(
                    value: $titleLineSpacing,
                    in: viewModel.titleLineSpacingRange,
                    step: 0.5
                ) {
                    Text("\(titleLineSpacing, specifier: "%.1f")")
                        .fontWeight(viewModel.titleLineSpacingChanged(titleLineSpacing) ? .bold : .regular)
                }
            }
        }
    }

    private var infoSection: some View {
        Section("Info") {
            VStack(alignment: .leading) {
                Text("Show Info\n(Content Characters, Content Line Numbers, Created At, Updated At)")
                    .font(.system(size: 12.0))
                Toggle(isOn: $showInfo) {
                    Text(showInfo ? "ON" : "OFF")
                        .fontWeight(viewModel.showInfoChanged(showInfo) ? .bold : .regular)
                }
            }
        }
    }

    private var searchSection: some View {
        Section("Search") {
            VStack(alignment: .leading) {
                Text("Divide Keywords By Space")
                    .font(.system(size: 12.0))
                Toggle(isOn: $divideKeywordsBySpace) {
                    Text(divideKeywordsBySpace ? "ON" : "OFF")
                        .fontWeight(viewModel.divideKeywordsBySpaceChanged(divideKeywordsBySpace) ? .bold : .regular)
                }
            }
        }
    }

    private var colorSection: some View {
        Section("Color") {
            VStack(alignment: .leading) {
                Text("Default Tag Color")
                    .font(.system(size: 12.0))
                HStack {
                    TagColorView(
                        colorString: defaultTagColor,
                        showColorString: true
                    )
                    Spacer()
                    ColorPicker(
                        "",
                        selection: $color,
                        supportsOpacity: false
                    )
                    .onChange(of: color) {
                        defaultTagColor = color.hexString()
                    }
                }
            }
        }
    }

    private var resetAlert: Alert {
        Alert(
            title: Text("Reset all settings?"),
            primaryButton: .destructive(Text("Reset")) {
                viewModel.reset()
                let snapshot = SettingsSnapshot(viewModel: viewModel)
                hasLink = snapshot.hasLink
                contentFontSize = snapshot.contentFontSize
                contentLineSpacing = snapshot.contentLineSpacing
                titleLineLimit = snapshot.titleLineLimit
                titleFontSize = snapshot.titleFontSize
                titleLineSpacing = snapshot.titleLineSpacing
                showInfo = snapshot.showInfo
                divideKeywordsBySpace = snapshot.divideKeywordsBySpace
                defaultTagColor = snapshot.defaultTagColor

                hasLinkToStore = snapshot.hasLink
                contentFontSizeToStore = snapshot.contentFontSize
                contentLineSpacingToStore = snapshot.contentLineSpacing
                titleLineLimitToStore = snapshot.titleLineLimit
                titleFontSizeToStore = snapshot.titleFontSize
                titleLineSpacingToStore = snapshot.titleLineSpacing
                showInfoToStore = snapshot.showInfo
                divideKeywordsBySpaceToStore = snapshot.divideKeywordsBySpace
                defaultTagColorToStore = snapshot.defaultTagColor
                toastMessage = "Successfully reset!"
            },
            secondaryButton: .cancel()
        )
    }

    /// ツールバーの右側のアイテムを生成するビュー。
    @ViewBuilder
    private var toolbarItemTopBarTrailing: some View {
        Button("Reset", systemImage: "xmark.circle.fill") {
            showResetAlert = true
        }
        .disabled(!viewModel.settingsChanged)
        .keyboardShortcut("r", modifiers: [.command])
        Button("Save", systemImage: "checkmark.circle.fill") {
            let snapshot = currentSnapshot
            save(snapshot: snapshot)
            hasLinkToStore = snapshot.hasLink
            contentFontSizeToStore = snapshot.contentFontSize
            contentLineSpacingToStore = snapshot.contentLineSpacing
            titleLineLimitToStore = snapshot.titleLineLimit
            titleFontSizeToStore = snapshot.titleFontSize
            titleLineSpacingToStore = snapshot.titleLineSpacing
            showInfoToStore = snapshot.showInfo
            divideKeywordsBySpaceToStore = snapshot.divideKeywordsBySpace
            defaultTagColorToStore = snapshot.defaultTagColor
            toastMessage = "Successfully saved!"
        }
        .disabled(!settingsUpdated)
        .keyboardShortcut("s", modifiers: [.command])
    }

    /// 設定が更新されたかどうかを判定するプロパティ。
    private var settingsUpdated: Bool {
        storeSnapshot != currentSnapshot
    }

    private var currentSnapshot: SettingsSnapshot {
        SettingsSnapshot(
            hasLink: hasLink,
            contentFontSize: contentFontSize,
            contentLineSpacing: contentLineSpacing,
            titleLineLimit: titleLineLimit,
            titleFontSize: titleFontSize,
            titleLineSpacing: titleLineSpacing,
            showInfo: showInfo,
            divideKeywordsBySpace: divideKeywordsBySpace,
            defaultTagColor: defaultTagColor
        )
    }

    private var storeSnapshot: SettingsSnapshot {
        SettingsSnapshot(
            hasLink: hasLinkToStore,
            contentFontSize: contentFontSizeToStore,
            contentLineSpacing: contentLineSpacingToStore,
            titleLineLimit: titleLineLimitToStore,
            titleFontSize: titleFontSizeToStore,
            titleLineSpacing: titleLineSpacingToStore,
            showInfo: showInfoToStore,
            divideKeywordsBySpace: divideKeywordsBySpaceToStore,
            defaultTagColor: defaultTagColorToStore
        )
    }

    private func save(snapshot: SettingsSnapshot) {
        viewModel.setHasLink(snapshot.hasLink)
        viewModel.setContentFontSize(snapshot.contentFontSize)
        viewModel.setContentLineSpacing(snapshot.contentLineSpacing)
        viewModel.setTitleLineLimit(snapshot.titleLineLimit)
        viewModel.setTitleFontSize(snapshot.titleFontSize)
        viewModel.setTitleLineSpacing(snapshot.titleLineSpacing)
        viewModel.setShowInfo(snapshot.showInfo)
        viewModel.setDivideKeywordsBySpace(snapshot.divideKeywordsBySpace)
        viewModel.setDefaultTagColor(snapshot.defaultTagColor)
    }

    private func rangeString<T: Equatable>(_ range: ClosedRange<T>) -> String {
        if let range = range as? ClosedRange<Int> {
            "\(String(range.lowerBound)) 〜 \(String(range.upperBound))"
        }
        else if let range = range as? ClosedRange<Float> {
            "\(String(format: "%.1f", range.lowerBound)) 〜 \(String(format: "%.1f", range.upperBound))"
        }
        else {
            ""
        }
    }
}

#Preview {
    SettingsView()
}
