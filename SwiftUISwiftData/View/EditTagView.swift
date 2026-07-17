//
//  EditTagView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import SwiftData
import SwiftUI

/// タグの内容を編集するビュー。
struct EditTagView: View {
    enum AlertType: Identifiable {
        case close
        case error
        var id: AlertType { self }
    }

    /// ビューモデルの状態変数。
    @ObservedObject
    var viewModel = EditTagViewModel(
        tagRepository: TagRepository(modelContainer: ModelContainerManager.shared.modelContainer),
        userDefaultsRepository: UserDefaultsRepository()
    )
    /// ビューを閉じるための環境変数。
    @Environment(\.dismiss)
    private var dismiss
    /// 編集中のタグ。
    @State
    private var tag: Tag?
    /// タイトルの状態変数。
    @State
    private var title: String
    /// 色の状態変数。
    @State
    private var colorString: String
    @State
    private var color: Color
    /// トーストメッセージの状態変数。
    @State
    private var toastMessage = ""
    /// テキストフィールドのフォーカス状態。
    @FocusState
    private var textFieldFocus: Bool
    @State
    private var error: Error?
    @State
    private var currentAlert: AlertType?
    /// ナビゲーションパスの状態変数。
    @State
    var path = NavigationPath()

    /// イニシャライザ。
    /// - Parameter tag: 編集するタグ（デフォルトはnilで新規作成）
    init(tag: Tag? = nil) {
        self.tag = tag
        _title = State(initialValue: tag?.title ?? "")
        _colorString = State(initialValue: tag?.color ?? "")
        _color = State(initialValue: tag?.color.color() ?? Color(red: .zero, green: .zero, blue: .zero))
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 4) {
                CustomTextField(
                    text: $title,
                    focus: _textFieldFocus,
                    placeholder: "Input Title",
                    background: Color(uiColor: .secondarySystemBackground),
                    submitLabel: .done,
                    icon: .none,
                    submitButtonTapped: nil
                )
                .padding(.bottom, 20)
                ColorPicker(
                    "Select Color",
                    selection: $color,
                    supportsOpacity: false
                )
                .onChange(of: color) {
                    colorString = color.hexString()
                }
                Text("\(color.hexString().color().hexString())")
                    .frame(maxWidth: .infinity)
                    .frame(height: 30.0)
                    .foregroundStyle(color.hexString().color().appropriateTextColor)
                    .background(color.hexString().color())
                Spacer()
                if viewModel.getShowInfo(), let tag {
                    InfoText.dateView(for: tag)
                }
            }
            .padding(.top, .zero)
            .padding(.horizontal)
            .padding(.bottom, 8)
            .onAppear {
                textFieldFocus = true
            }
            .alert(item: $currentAlert) { alertType in
                switch alertType {
                    case .close:
                        closeAlert
                    case .error:
                        errorAlert
                }
            }
            .navigationTitle(tag?.title ?? "Add Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(uiColor: .systemBackground), for: .navigationBar)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    toolbarItemTopBarLeading
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    toolbarItemTopBarTrailing
                }
            }
            .toast(message: $toastMessage)
        }
    }

    private var closeAlert: Alert {
        Alert(
            title: Text("Close without saving?"),
            primaryButton: .destructive(Text("Close")) {
                dismiss()
            },
            secondaryButton: .cancel()
        )
    }

    private var errorAlert: Alert {
        .init(
            title: Text("The Error occured."),
            message: Text(error?.localizedDescription ?? ""),
            dismissButton: .default(Text("OK"))
        )
    }

    /// ツールバーの左側のアイテムを定義するビュー。
    ///
    /// 変更がある場合は確認アラートを表示し、変更がない場合はビューを閉じる。
    @ViewBuilder
    private var toolbarItemTopBarLeading: some View {
        Button("Close", systemImage: "xmark") {
            if tagUpdated {
                currentAlert = .close
            }
            else {
                dismiss()
            }
        }
    }

    /// ツールバーの右側のアイテムを定義するビュー。
    ///
    /// タイトルが空でない場合はリネームのボタンを表示し、常に保存のボタンを表示する。保存のボタンは変更がある場合のみ有効になる。
    @ViewBuilder
    private var toolbarItemTopBarTrailing: some View {
        Button("Save", systemImage: "square.and.pencil") {
            if let tag {
                let oldTitle = tag.title
                let oldColor = tag.color

                do {
                    try viewModel.update(tag, title: title, color: colorString)
                    toastMessage = "Successfully saved!"
                }
                catch {
                    self.error = error
                    currentAlert = .error

                    tag.title = oldTitle
                    tag.color = oldColor
                    print("Failed to update tag: \(error)")
                }
            }
            else {
                let tag = Tag(title: title, color: colorString)

                do {
                    try viewModel.add(tag)
                    self.tag = tag
                    toastMessage = "Successfully saved!"
                }
                catch {
                    self.error = error
                    currentAlert = .error
                    print("Failed to add tag: \(error)")
                }
            }
        }
        .disabled(!tagUpdated)
        .keyboardShortcut("s", modifiers: [.command])
    }

    /// タグが更新されたかどうかを判定するプロパティ。
    ///
    /// 既存のタグがある場合はタイトルまたは色が変更されたかどうかを確認し、既存のタグがない場合はタイトルまたは色が空でないかどうかを確認する。
    private var tagUpdated: Bool {
        if let tag {
            tag.title != title || tag.color != colorString
        }
        else {
            !title.isEmpty || !colorString.isEmpty
        }
    }
}

#Preview {
    NavigationStack {
        let tag = Tag(title: "Sample Title", color: "#000000", createdAt: Date(), updatedAt: Date(), order: .zero)
        EditTagView(tag: tag)
    }
}
