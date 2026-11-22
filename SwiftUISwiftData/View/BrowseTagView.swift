//
//  BrowseTagView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import SwiftData
import SwiftUI

/// タグの内容を表示するビュー。
struct BrowseTagView: View {
    @Environment(\.modelContext)
    private var modelContext
    /// ビューの状態を管理する ViewModel。
    @State
    private var viewModel: BrowseTagViewModel
    /// ナビゲーションパス。
    @State
    private var path = NavigationPath()

    /// タグと Repository からビューを生成する。
    ///
    /// Repository を省略した場合は通常の UserDefaults を使用する。
    init(
        tag: Tag,
        userDefaultsRepository: UserDefaultsRepository = UserDefaultsRepository()
    ) {
        self.init(
            viewModel: BrowseTagViewModel(
                tag: tag,
                userDefaultsRepository: userDefaultsRepository
            )
        )
    }

    /// 外部で生成した ViewModel を使用する。
    init(viewModel: BrowseTagViewModel) {
        _viewModel = State(initialValue: viewModel)
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
            .sheet(isPresented: showingEditTagBinding) {
                EditTagView(
                    viewModel: viewModel.makeEditTagViewModel(
                        modelContext: modelContext
                    )
                )
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

    /// 編集画面の表示状態を ViewModel の操作に接続する。
    private var showingEditTagBinding: Binding<Bool> {
        Binding(
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
    }

    @ViewBuilder
    private var toolbarItemTopBarTrailing: some View {
        Button("Edit", systemImage: "pencil") {
            viewModel.editButtonTapped()
        }
        .keyboardShortcut("e", modifiers: [.command, .shift])
    }
}

#Preview("white") {
    let tag = Tag(
        title: "Sample Title",
        color: "#FFFFFF",
        createdAt: Date(),
        updatedAt: Date(),
        order: .zero
    )

    BrowseTagView(
        viewModel: BrowseTagViewModel(
            tag: tag,
            userDefaultsRepository: UserDefaultsRepository()
        )
    )
}

#Preview("black") {
    let tag = Tag(
        title: "Sample Title",
        color: "#000000",
        createdAt: Date(),
        updatedAt: Date(),
        order: .zero
    )

    BrowseTagView(tag: tag)
}
