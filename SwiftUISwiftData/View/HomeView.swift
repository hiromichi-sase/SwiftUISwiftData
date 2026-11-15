//
//  HomeView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/05.
//

import SwiftUI

struct HomeView: View {
    @Bindable
    var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        List(viewModel.menuItems, selection: $viewModel.selectedSection) { item in
            HStack {
                Image(systemName: item.icon)
                    .frame(maxWidth: 24.0)
                Text(item.title)
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
        .navigationTitle(viewModel.appName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        HomeView(
            viewModel: HomeViewModel(
                selectedSection: .memos,
                appNameProvider: { "SwiftUISwiftData" }
            )
        )
    }
}
