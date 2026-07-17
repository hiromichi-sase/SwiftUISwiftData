//
//  GlassButton.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/05.
//

import SwiftUI

struct GlassButton: View {
    @State
    var imageSystemName: String
    var action: (() -> Void)?

    var body: some View {
        Button {
            action?()
        } label: {
            Image(systemName: imageSystemName)
                .font(.system(size: 29))
                .fontWeight(.light)
        }
        .buttonBorderShape(.circle)
        .buttonStyle(.glass)
    }
}

#Preview {
    GlassButton(imageSystemName: "tag")
}
