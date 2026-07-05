//
//  GlassMenu.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/05.
//

import SwiftUI

struct GlassMenu<Content: View>: View {
    @State
    var imageSystemName: String
    @ViewBuilder
    var content: () -> Content

    var body: some View {
        Menu {
            content()
        } label: {
            Image(systemName: imageSystemName)
                .font(.system(size: 22))
                .frame(width: 34, height: 34)
        }
        .buttonBorderShape(.circle)
        .buttonStyle(.glass)
    }
}
