//
//  BrowseTextView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/05/24.
//

import SwiftUI

struct BrowseTextView: UIViewRepresentable {
    @Binding var text: String

    func makeCoordinator() -> Coordinator {
        Coordinator($text)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isEditable = false
        textView.dataDetectorTypes = .all
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        if text.isEmpty {
            uiView.text = "(No content)"
        }
        uiView.textColor = text.isEmpty ? .secondaryLabel : .label
    }
}
