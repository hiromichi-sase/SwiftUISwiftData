//
//  InputView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/30.
//

import SwiftUI

struct InputView: View {
    enum Icon {
        case search
        case none

        var systemName: String {
            switch self {
                case .search:
                    "magnifyingglass"
                case .none:
                    ""
            }
        }
    }

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
    @State
    var icon: Icon = .none
    var submitButtonTapped: (() -> Void)?
    var cancelButtonTapped: (() -> Void)?

    var body: some View {
        HStack(spacing: 0.0) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(textFieldBackground)
                    .frame(height: 48)
                HStack(spacing: 6) {
                    Spacer()
                        .frame(width: 12)
                    if !icon.systemName.isEmpty {
                        Image(systemName: icon.systemName)
                            .foregroundColor(.gray)
                    }
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
            .keyboardShortcut(".", modifiers: [.command])
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
        placeholder: "Input search text",
        textFieldBackground: Color(uiColor: .secondarySystemBackground)
    )
    .onAppear {
        focus = true
    }
}
