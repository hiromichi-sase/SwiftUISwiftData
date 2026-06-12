//
//  SettingsView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/07.
//

import SwiftData
import SwiftUI

/// 設定画面を表示するビュー
struct SettingsView: View {
    /// ビューの状態を管理するViewModel
    @ObservedObject var viewModel = SettingsViewModel(
        userDefaultsRepository: UserDefaultsRepository()
    )

    @Binding private var settingsSaved: Bool
    @State private var hasLink: Bool = false
    @State private var contentFontSize: Float = .zero
    @State private var contentLineSpacing: Float = .zero
    @State private var titleLineLimit: Int = .zero
    @State private var titleFontSize: Float = .zero
    @State private var titleLineSpacing: Float = .zero
    @State private var showDate: Bool = false
    @State private var showResetAlert = false

    /// ビューを閉じるための環境変数
    @Environment(\.dismiss)
    private var dismiss

    init(settingsSaved: Binding<Bool>) {
        self._settingsSaved = settingsSaved
        self._hasLink = State(initialValue: viewModel.getHasLink())
        self._contentFontSize = State(initialValue: viewModel.getContentFontSize())
        self._contentLineSpacing = State(initialValue: viewModel.getContentLineSpacing())
        self._titleLineLimit = State(initialValue: viewModel.getTitleLineLimit())
        self._titleFontSize = State(initialValue: viewModel.getTitleFontSize())
        self._titleLineSpacing = State(initialValue: viewModel.getTitleLineSpacing())
        self._showDate = State(initialValue: viewModel.getShowDate())
    }

    var body: some View {
        NavigationStack {
            Form {
                browseSection
                contentSection
                titleSection
                dateSection
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
        }
    }

    private var browseSection: some View {
        Section("Browse") {
            VStack(alignment: .leading) {
                Text("Has Link")
                    .font(.system(size: 12.0))
                Toggle(isOn: $hasLink) {
                    Text(hasLink ? "ON" : "OFF")
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
                }
            }
        }
    }

    private var dateSection: some View {
        Section("Date") {
            VStack(alignment: .leading) {
                Text("Show Date(CreatedAt, UpdatedAt)")
                    .font(.system(size: 12.0))
                Toggle(isOn: $showDate) {
                    Text(showDate ? "ON" : "OFF")
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
                showDate = viewModel.getShowDate()
                settingsSaved = true
            },
            secondaryButton: .cancel()
        )
    }

    /// ツールバーの右側のアイテムを生成するビュー
    @ViewBuilder private var toolbarItemTopBarTrailing: some View {
        Button("Reset", systemImage: "xmark.circle.fill") {
            showResetAlert = true
        }
        .disabled(!viewModel.settingsChanged)
        Button("Save", systemImage: "checkmark") {
            viewModel.setHasLink(hasLink)
            viewModel.setContentFontSize(contentFontSize)
            viewModel.setContentLineSpacing(contentLineSpacing)
            viewModel.setTitleLineLimit(titleLineLimit)
            viewModel.setTitleFontSize(titleFontSize)
            viewModel.setTitleLineSpacing(titleLineSpacing)
            viewModel.setShowDate(showDate)
            settingsSaved = true
            dismiss()
        }
        .disabled(!settingsUpdated)
    }

    /// 設定が更新されたかどうかを判定するプロパティ
    private var settingsUpdated: Bool {
        viewModel.getHasLink() != hasLink ||
        viewModel.getContentFontSize() != contentFontSize ||
        viewModel.getContentLineSpacing() != contentLineSpacing ||
        viewModel.getTitleLineLimit() != titleLineLimit ||
        viewModel.getTitleFontSize() != titleFontSize ||
        viewModel.getTitleLineSpacing() != titleLineSpacing ||
        viewModel.getShowDate() != showDate
    }

    private func rangeString<T: Equatable>(_ range: ClosedRange<T>) -> String {
        if let range = range as? ClosedRange<Int> {
            "\(String(range.lowerBound)) 〜 \(String(range.upperBound))"
        } else if let range = range as? ClosedRange<Float> {
            "\(String(format: "%.1f", range.lowerBound)) 〜 \(String(format: "%.1f", range.upperBound))"
        } else {
            ""
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(settingsSaved: .constant(true))
    }
}
