//
//  SettingsView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/07.
//

import SwiftUI
import SwiftData

/// 設定画面を表示するビュー
struct SettingsView: View {
    /// ビューの状態を管理するViewModel
    @ObservedObject var viewModel = SettingsViewModel(
        userDefaultsRepository: UserDefaultsRepository()
    )

    @State private var hasLink: Bool = false
    @State private var contentFontSize: Float = .zero
    @State private var contentLineSpacing: Float = .zero
    @State private var titleLineLimit: Int = .zero

    /// ビューを閉じるための環境変数
    @Environment(\.dismiss) private var dismiss

    init() {
        self._hasLink = State(initialValue: viewModel.getHasLink())
        self._contentFontSize = State(initialValue: viewModel.getContentFontSize())
        self._contentLineSpacing = State(initialValue: viewModel.getContentLineSpacing())
        self._titleLineLimit = State(initialValue: viewModel.getTitleLineLimit())
    }

    var body: some View {
        NavigationStack() {
            Form {
                Section(header: Text("Has Link")) {
                    Toggle(isOn: $hasLink) {
                        Text(hasLink ? "ON" : "OFF")
                    }
                }
                Section(header: Text("Content Font Size")) {
                    Stepper(value: $contentFontSize, in: 5.0 ... 100, step: 0.5) {
                        Text("\(contentFontSize, specifier: "%.1f")")
                    }
                }
                Section(header: Text("Content Line Spacing")) {
                    Stepper(value: $contentLineSpacing, in: 0.0 ... 10.0, step: 0.5) {
                        Text("\(contentLineSpacing, specifier: "%.1f")")
                    }
                }
                Section(header: Text("Title Line Limit")) {
                    Stepper(value: $titleLineLimit, in: 1 ... 5) {
                        Text("\(titleLineLimit)")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Save", systemImage: "checkmark") {
                        if viewModel.getHasLink() != hasLink {
                            viewModel.setHasLink(hasLink)
                        }
                        if viewModel.getContentFontSize() != contentFontSize {
                            viewModel.setContentFontSize(contentFontSize)
                        }
                        if viewModel.getContentLineSpacing() != contentLineSpacing {
                            viewModel.setContentLineSpacing(contentLineSpacing)
                        }
                        if viewModel.getTitleLineLimit() != titleLineLimit {
                            viewModel.setTitleLineLimit(titleLineLimit)
                        }
                        dismiss()
                    }
                    .disabled(!settingsUpdated)
                }
            }
        }
    }

    /// 設定が更新されたかどうかを判定するプロパティ
    private var settingsUpdated: Bool {
        viewModel.getHasLink() != hasLink ||
        viewModel.getContentFontSize() != contentFontSize ||
        viewModel.getContentLineSpacing() != contentLineSpacing ||
        viewModel.getTitleLineLimit() != titleLineLimit
    }
}
