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

    /// トーストメッセージの状態変数。
    @State
    private var toastMessage = ""
    @State
    private var showResetAlert = false
    /// ビューを閉じるための環境変数。
    @Environment(\.dismiss)
    private var dismiss

    init() {
        _hasLink = State(initialValue: viewModel.getHasLink())
        _contentFontSize = State(initialValue: viewModel.getContentFontSize())
        _contentLineSpacing = State(initialValue: viewModel.getContentLineSpacing())
        _titleLineLimit = State(initialValue: viewModel.getTitleLineLimit())
        _titleFontSize = State(initialValue: viewModel.getTitleFontSize())
        _titleLineSpacing = State(initialValue: viewModel.getTitleLineSpacing())
        _showInfo = State(initialValue: viewModel.getShowInfo())

        _hasLinkToStore = State(initialValue: viewModel.getHasLink())
        _contentFontSizeToStore = State(initialValue: viewModel.getContentFontSize())
        _contentLineSpacingToStore = State(initialValue: viewModel.getContentLineSpacing())
        _titleLineLimitToStore = State(initialValue: viewModel.getTitleLineLimit())
        _titleFontSizeToStore = State(initialValue: viewModel.getTitleFontSize())
        _titleLineSpacingToStore = State(initialValue: viewModel.getTitleLineSpacing())
        _showInfoToStore = State(initialValue: viewModel.getShowInfo())
    }

    var body: some View {
        NavigationStack {
            Form {
                browseSection
                contentSection
                titleSection
                infoSection
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

    private var resetAlert: Alert {
        Alert(
            title: Text("Reset all settings?"),
            primaryButton: .destructive(Text("Reset")) {
                viewModel.reset()
                hasLink = viewModel.getHasLink()
                contentFontSize = viewModel.getContentFontSize()
                contentLineSpacing = viewModel.getContentLineSpacing()
                titleLineLimit = viewModel.getTitleLineLimit()
                titleFontSize = viewModel.getTitleFontSize()
                titleLineSpacing = viewModel.getTitleLineSpacing()
                showInfo = viewModel.getShowInfo()
                updateStore()
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
            viewModel.setHasLink(hasLink)
            viewModel.setContentFontSize(contentFontSize)
            viewModel.setContentLineSpacing(contentLineSpacing)
            viewModel.setTitleLineLimit(titleLineLimit)
            viewModel.setTitleFontSize(titleFontSize)
            viewModel.setTitleLineSpacing(titleLineSpacing)
            viewModel.setShowInfo(showInfo)
            updateStore()
            toastMessage = "Successfully saved!"
        }
        .disabled(!settingsUpdated)
        .keyboardShortcut("s", modifiers: [.command])
    }

    /// 設定が更新されたかどうかを判定するプロパティ。
    private var settingsUpdated: Bool {
        guard hasLinkToStore == hasLink else { return true }
        guard contentFontSizeToStore == contentFontSize else { return true }
        guard contentLineSpacingToStore == contentLineSpacing else { return true }
        guard titleLineLimitToStore == titleLineLimit else { return true }
        guard titleFontSizeToStore == titleFontSize else { return true }
        guard titleLineSpacingToStore == titleLineSpacing else { return true }
        guard showInfoToStore == showInfo else { return true }
        return false
    }

    private func updateStore() {
        hasLinkToStore = hasLink
        contentFontSizeToStore = contentFontSize
        contentLineSpacingToStore = contentLineSpacing
        titleLineLimitToStore = titleLineLimit
        titleFontSizeToStore = titleFontSize
        titleLineSpacingToStore = titleLineSpacing
        showInfoToStore = showInfo
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
