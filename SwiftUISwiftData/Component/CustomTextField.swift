//
//  CustomTextField.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/17.
//

import SwiftUI

struct CustomTextField: View {
    @Binding
    var text: String
    @FocusState
    var focus: Bool
    @State
    var placeholder: String
    @State
    var background: Color
    @State
    var submitLabel: SubmitLabel = .done
    var submitButtonTapped: (() -> Void)?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(background)
                .frame(height: 48)
            HStack(spacing: 6) {
                Spacer()
                    .frame(width: 12)
                TextField(placeholder, text: $text)
                    .focused($focus)
                    .submitLabel(submitLabel)
                    .onSubmit {
                        submitButtonTapped?()
                    }
                Spacer()
                    .frame(width: 8)
            }
        }
    }
}

#Preview {
    @Previewable
    @FocusState
    var focus: Bool

    CustomTextField(
        text: Binding(projectedValue: .constant("a b c")),
        focus: _focus,
        placeholder: "Input search text",
        background: Color(uiColor: .secondarySystemBackground)
    )
    .onAppear {
        focus = true
    }
}
