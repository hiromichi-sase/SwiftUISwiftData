//
//  BrowseTagView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import SwiftData
import SwiftUI

/// メモの内容を表示するビュー。
struct BrowseTagView: View {
    /// ビューの状態を管理するViewModel。
    @ObservedObject
    var viewModel = BrowseTagViewModel(
        userDefaultsRepository: UserDefaultsRepository()
    )
    /// 表示するメモ。
    @State
    private var tag: Tag
    /// 編集画面を表示するかどうかのフラグ。
    @State
    private var showingEditTag = false
    /// トーストメッセージの状態変数。
    @State
    private var toastMessage = ""
    /// ナビゲーションパスの状態変数。
    @State
    var path = NavigationPath()

    /// イニシャライザ。
    /// - Parameter tag: 表示するメモ
    init(tag: Tag) {
        self.tag = tag
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 4) {
                Spacer()
                    .frame(height: 0)
                Text(tag.color)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(tag.color.color().appropriateTextColor)
                    .background(tag.color.color())
                Spacer()
                if viewModel.getShowInfo() {
                    InfoText.dateView(for: tag)
                }
            }
            .padding(.top, .zero)
            .padding([.horizontal, .bottom], 16)
            .sheet(isPresented: $showingEditTag) {
                EditTagView(tag: tag)
                    .interactiveDismissDisabled(true)
            }
            .navigationTitle(tag.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    toolbarItemTopBarTrailing
                }
            }
            .toast(message: $toastMessage)
        }
    }

    /// ツールバーの右側のアイテムを定義するビュー。
    ///
    /// タイトルが空でない場合はコピーのボタンを表示し、常に編集のボタンを表示する。
    @ViewBuilder
    private var toolbarItemTopBarTrailing: some View {
        if !tag.title.isEmpty {
            Button("Copy", systemImage: "doc.on.doc") {
                UIPasteboard.general.string = tag.title
                toastMessage = "Successfully copied!"
            }
            .keyboardShortcut("c", modifiers: [.command, .shift])
        }
        Button("Edit", systemImage: "pencil") {
            showingEditTag = true
        }
        .keyboardShortcut("e", modifiers: [.command, .shift])
    }
}

#Preview {
    NavigationStack {
        let tag = Tag(title: "Sample Title", color: "#00FF00", createdAt: Date(), updatedAt: Date(), order: .zero)
        BrowseTagView(tag: tag)
    }
}
