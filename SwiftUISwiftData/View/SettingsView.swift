//
//  SettingsView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/07.
//

import SwiftUI

/// 設定画面を表示するビュー。
struct SettingsView: View {
    @State
    private var viewModel: SettingsViewModel

    @State
    private var toastMessage = ""

    @State
    private var showResetAlert = false

    /// 通常の依存関係を使用してビューを生成する。
    init() {
        self.init(
            viewModel: SettingsViewModel(
                userDefaultsRepository: UserDefaultsRepository()
            )
        )
    }

    /// 外部で生成した ViewModel を使用する。
    init(viewModel: SettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Form {
                browseSection
                contentSection
                titleSection
                infoSection
                colorSection
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

                Toggle(isOn: $viewModel.draft.hasLink) {
                    Text(viewModel.draft.hasLink ? "ON" : "OFF")
                        .fontWeight(
                            viewModel.hasLinkChanged(viewModel.draft.hasLink)
                                ? .bold
                                : .regular
                        )
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
                    value: $viewModel.draft.contentFontSize,
                    in: viewModel.contentFontSizeRange,
                    step: 0.5
                ) {
                    Text("\(viewModel.draft.contentFontSize, specifier: "%.1f")")
                        .fontWeight(
                            viewModel.contentFontSizeChanged(viewModel.draft.contentFontSize)
                                ? .bold
                                : .regular
                        )
                }
            }

            VStack(alignment: .leading) {
                Text("Line Spacing (\(rangeString(viewModel.contentLineSpacingRange)))")
                    .font(.system(size: 12.0))

                Stepper(
                    value: $viewModel.draft.contentLineSpacing,
                    in: viewModel.contentLineSpacingRange,
                    step: 0.5
                ) {
                    Text("\(viewModel.draft.contentLineSpacing, specifier: "%.1f")")
                        .fontWeight(
                            viewModel.contentLineSpacingChanged(viewModel.draft.contentLineSpacing)
                                ? .bold
                                : .regular
                        )
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
                    value: $viewModel.draft.titleLineLimit,
                    in: viewModel.titleLineLimitRange
                ) {
                    Text("\(viewModel.draft.titleLineLimit)")
                        .fontWeight(
                            viewModel.titleLineLimitChanged(viewModel.draft.titleLineLimit)
                                ? .bold
                                : .regular
                        )
                }
            }

            VStack(alignment: .leading) {
                Text("Font Size (\(rangeString(viewModel.titleFontSizeRange)))")
                    .font(.system(size: 12.0))

                Stepper(
                    value: $viewModel.draft.titleFontSize,
                    in: viewModel.titleFontSizeRange,
                    step: 0.5
                ) {
                    Text("\(viewModel.draft.titleFontSize, specifier: "%.1f")")
                        .fontWeight(
                            viewModel.titleFontSizeChanged(viewModel.draft.titleFontSize)
                                ? .bold
                                : .regular
                        )
                }
            }

            VStack(alignment: .leading) {
                Text("Line Spacing (\(rangeString(viewModel.titleLineSpacingRange)))")
                    .font(.system(size: 12.0))

                Stepper(
                    value: $viewModel.draft.titleLineSpacing,
                    in: viewModel.titleLineSpacingRange,
                    step: 0.5
                ) {
                    Text("\(viewModel.draft.titleLineSpacing, specifier: "%.1f")")
                        .fontWeight(
                            viewModel.titleLineSpacingChanged(viewModel.draft.titleLineSpacing)
                                ? .bold
                                : .regular
                        )
                }
            }
        }
    }

    private var infoSection: some View {
        Section("Info") {
            VStack(alignment: .leading) {
                Text("Show Info\n(Content Characters, Content Line Numbers, Created At, Updated At)")
                    .font(.system(size: 12.0))

                Toggle(isOn: $viewModel.draft.showInfo) {
                    Text(viewModel.draft.showInfo ? "ON" : "OFF")
                        .fontWeight(
                            viewModel.showInfoChanged(viewModel.draft.showInfo)
                                ? .bold
                                : .regular
                        )
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
                        colorString: viewModel.draft.defaultTagColor,
                        showColorString: true
                    )

                    Spacer()

                    ColorPicker(
                        "",
                        selection: defaultTagColorBinding,
                        supportsOpacity: false
                    )
                }
            }
        }
    }

    private var defaultTagColorBinding: Binding<Color> {
        Binding(
            get: {
                viewModel.draft.defaultTagColor.color()
            },
            set: { color in
                viewModel.draft.defaultTagColor = color.hexString()
            }
        )
    }

    private var resetAlert: Alert {
        Alert(
            title: Text("Reset all settings?"),
            primaryButton: .destructive(Text("Reset")) {
                viewModel.reset()
                toastMessage = "Successfully reset!"
            },
            secondaryButton: .cancel()
        )
    }

    @ViewBuilder
    private var toolbarItemTopBarTrailing: some View {
        Button("Reset", systemImage: "xmark.circle.fill") {
            showResetAlert = true
        }
        .disabled(!viewModel.settingsChanged)
        .keyboardShortcut("r", modifiers: [.command])

        Button("Save", systemImage: "checkmark.circle.fill") {
            viewModel.save()
            toastMessage = "Successfully saved!"
        }
        .disabled(!viewModel.canSave)
        .keyboardShortcut("s", modifiers: [.command])
    }

    private func rangeString(_ range: ClosedRange<Int>) -> String {
        "\(range.lowerBound) 〜 \(range.upperBound)"
    }

    private func rangeString(_ range: ClosedRange<Float>) -> String {
        "\(String(format: "%.1f", range.lowerBound)) 〜 \(String(format: "%.1f", range.upperBound))"
    }
}

#Preview {
    SettingsView()
}
