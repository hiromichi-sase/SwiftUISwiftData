//
//  TextView.swift
//  SwiftUICoreData
//
//  Created by Hiromichi Sase on 2026/05/04.
//

import SwiftUI

struct TextView: UIViewRepresentable {
    @Binding var text: String
    var isEditable: Bool

    init(text: Binding<String>, isEditable: Bool) {
        self._text = text
        self.isEditable = isEditable
    }

    func makeCoordinator() -> Coordinator {
        Coordinator($text)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isEditable = isEditable
        textView.textColor = textColor
        textView.dataDetectorTypes = .all
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        uiView.textColor = textColor
    }

    private var textColor: UIColor {
        isEditable ? .label : .secondaryLabel
    }
}

class Coordinator: NSObject, UITextViewDelegate {
    var text: Binding<String>

    init(_ text: Binding<String>) {
        self.text = text
    }

    func textViewDidChange(_ textView: UITextView) {
        self.text.wrappedValue = textView.text
    }
}
