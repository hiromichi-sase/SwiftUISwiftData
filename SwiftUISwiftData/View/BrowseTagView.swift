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
    @State
    private var viewModel: BrowseTagViewModel
    /// ナビゲーションパスの状態変数。
    @State
    var path = NavigationPath()

    /// イニシャライザ。
    /// - Parameter tag: 表示するタグ
    init(tag: Tag) {
        _viewModel = State(
            wrappedValue: BrowseTagViewModel(
                tag: tag,
                userDefaultsRepository: UserDefaultsRepository(),
            )
        )
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 4) {
                Spacer()
                    .frame(height: .zero)
                HStack {
                    TagColorView(
                        colorString: viewModel.tag.color,
                        showColorString: true
                    )
                }
                .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
                if viewModel.showInfo {
                    InfoText.dateView(for: viewModel.tag)
                }
            }
            .padding(.top, .zero)
            .padding([.horizontal, .bottom], 16)
            .sheet(
                isPresented: Binding(
                    get: { viewModel.showingEditTag },
                    set: { newValue in
                        if newValue {
                            viewModel.editButtonTapped()
                        }
                        else {
                            viewModel.dismissEdit()
                        }
                    }
                )
            ) {
                EditTagView(tag: viewModel.tag)
                    .interactiveDismissDisabled(true)
            }
            .navigationTitle(viewModel.tag.title)
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
            viewModel.editButtonTapped()
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
