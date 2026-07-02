//
//  SearchView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/30.
//

import SwiftUI

struct SearchView: View {
    @Binding
    var text: String
    @FocusState
    var focus: Bool
    @State
    var placeholder: String
    var cancelButtonTapped: (() -> Void)?

    var body: some View {
        HStack(spacing: 0.0) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(uiColor: .tertiarySystemBackground))
                    .frame(height: 48)
                HStack(spacing: 6) {
                    Spacer()
                        .frame(width: 12)
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField(placeholder, text: $text)
                        .focused($focus)
                        .submitLabel(.done)
                    Spacer()
                        .frame(width: 8)
                }
            }
            .padding(.trailing, 7)
            Button {
                cancelButtonTapped?()
            } label: {
                Image(systemName: "xmark.circle")
                    .font(.system(size: 29))
                    .fontWeight(.light)
            }
            .padding(.leading, 0)
            .padding(.trailing, -5)
            .buttonBorderShape(.circle)
            .buttonStyle(.glass)
            .keyboardShortcut(.cancelAction)
        }
    }
}

#Preview {
    @Previewable
    @FocusState
    var focus: Bool

    SearchView(
        text: Binding(projectedValue: .constant("a b c")),
        focus: _focus,
        placeholder: "Input search text"
    )
    .onAppear {
        focus = true
    }
}
