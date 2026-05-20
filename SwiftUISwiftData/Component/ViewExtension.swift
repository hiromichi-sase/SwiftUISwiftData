//
//  ViewExtension.swift
//  SwiftUICoreData
//
//  Created by Hiromichi Sase on 2026/05/04.
//

import SwiftUI

extension View {
    @ViewBuilder
    func navigationTitle(_ title: Binding<String>, disabled: Bool) -> some View {
        if disabled {
            if title.wrappedValue.isEmpty {
                navigationTitle("")
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("(No Title)")
                                .foregroundStyle(.secondary)
                        }
                    }
            } else {
                navigationTitle(title.wrappedValue)
                    .toolbarTitleMenu {
                        Button("Copy", systemImage: "doc.on.doc") {
                            UIPasteboard.general.string = title.wrappedValue
                        }
                    }
            }
        } else {
            navigationTitle("")
        }
    }
}
