//
//  InputView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/30.
//

import SwiftUI

struct InputView: View {
    @Binding
    var text: String
    @FocusState
    var focus: Bool
    @State
    var placeholder: String
    @State
    var textFieldBackground: Color
    @State
    var submitLabel: SubmitLabel = .done
    var submitButtonTapped: (() -> Void)?
    var cancelButtonTapped: (() -> Void)?

    var body: some View {
        HStack(spacing: 0.0) {
            GlassButton(imageSystemName: "xmark.circle") {
                cancelButtonTapped?()
            }
            .padding(.leading, -5)
            .keyboardShortcut(".", modifiers: [.command])
            CustomTextField(
                text: $text,
                focus: _focus,
                placeholder: placeholder,
                background: textFieldBackground,
                submitLabel: submitLabel,
                submitButtonTapped: submitButtonTapped
            )
        }
    }
}

#Preview {
    @Previewable
    @FocusState
    var focus: Bool

    InputView(
        text: Binding(projectedValue: .constant("a b c")),
        focus: _focus,
        placeholder: "Input Keywords",
        textFieldBackground: Color(uiColor: .secondarySystemBackground)
    )
    .onAppear {
        focus = true
    }
}
