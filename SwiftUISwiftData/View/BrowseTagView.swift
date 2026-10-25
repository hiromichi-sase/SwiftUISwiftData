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
    /// ナビゲーションパスの状態変数。
    @State
    var path = NavigationPath()

    /// イニシャライザ。
    /// - Parameter tag: 表示するタグ
    init(tag: Tag) {
        self.tag = tag
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 4) {
                Spacer()
                    .frame(height: .zero)
                HStack {
                    TagColorView(
                        colorString: tag.color,
                        showColorString: true
                    )
                }
                .frame(maxWidth: .infinity, alignment: .center)
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
        }
    }

    /// ツールバーの右側のアイテムを定義するビュー。
    ///
    /// タイトルが空でない場合はコピーのボタンを表示し、常に編集のボタンを表示する。
    @ViewBuilder
    private var toolbarItemTopBarTrailing: some View {
        Button("Edit", systemImage: "pencil") {
            showingEditTag = true
        }
        .keyboardShortcut("e", modifiers: [.command, .shift])
    }
}

#Preview("white") {
    NavigationStack {
        let tag = Tag(title: "Sample Title", color: "#FFFFFF", createdAt: Date(), updatedAt: Date(), order: .zero)
        BrowseTagView(tag: tag)
    }
}

#Preview("black") {
    NavigationStack {
        let tag = Tag(title: "Sample Title", color: "#000000", createdAt: Date(), updatedAt: Date(), order: .zero)
        BrowseTagView(tag: tag)
    }
}
