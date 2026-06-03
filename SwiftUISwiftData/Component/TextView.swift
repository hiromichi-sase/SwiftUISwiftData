//
//  TextView.swift
//  SwiftUICoreData
//
//  Created by Hiromichi Sase on 2026/05/04.
//

import SwiftUI

/// A SwiftUI wrapper for UITextView that supports multi-line text input and editing.
struct TextView: UIViewRepresentable {
    /// The text content of the TextView, bound to a SwiftUI state variable.
    @Binding var text: String
    /// A flag indicating whether the TextView is editable or read-only.
    var isEditable: Bool
    /// An optional default text to display when the TextView is empty and not editable.
    var defaultText: String?

    /// Initializes a new TextView with the specified parameters.
    /// - Parameters:
    ///   - text: The text content of the TextView, bound to a SwiftUI state variable.
    ///   - isEditable: A flag indicating whether the TextView is editable or read-only.
    ///   - defaultText: An optional default text to display when the TextView is empty and not editable. display when the TextView is empty and not editable.
    init(text: Binding<String>, isEditable: Bool, defaultText: String? = nil) {
        self._text = text
        self.isEditable = isEditable
        self.defaultText = defaultText
    }

    /// Creates a coordinator to manage the communication between the UITextView and SwiftUI.
    /// - Returns: A Coordinator instance that serves as the delegate for the UITextView.
    func makeCoordinator() -> Coordinator {
        Coordinator($text)
    }

    /// Creates and configures a UITextView instance to be used as the underlying view for the TextView.
    /// - Parameter context: The context for the UIView.
    /// - Returns: A UITextView instance.
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isEditable = isEditable
        textView.dataDetectorTypes = .all
        return textView
    }

    /// Updates the UITextView instance with the latest text content and configuration whenever the SwiftUI state changes.
    /// - Parameters:
    ///   - uiView: The UITextView instance to be updated.
    ///   - context: The context for the UIView.
    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }

        if let defaultText, text.isEmpty {
            uiView.text = defaultText
        }

        uiView.textColor = !text.isEmpty && isEditable ? .label : .secondaryLabel
    }
}

/// A coordinator class that serves as the delegate for the UITextView, allowing it to communicate changes back to SwiftUI.
class Coordinator: NSObject, UITextViewDelegate {
    /// A binding to the text content of the TextView, allowing it to update the SwiftUI state whenever the text changes.
    var text: Binding<String>

    /// Initializes a new Coordinator with the specified text binding.
    /// - Parameter text: A binding to the text content of the TextView.
    init(_ text: Binding<String>) {
        self.text = text
    }

    /// Called whenever the text in the UITextView changes, allowing the Coordinator to update the SwiftUI state with the new text content.
    /// - Parameter textView: The UITextView instance whose text has changed.
    func textViewDidChange(_ textView: UITextView) {
        self.text.wrappedValue = textView.text
    }
}
