//
//  Coordinator.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/12.
//

import SwiftUI

/// A coordinator class that serves as the delegate for the UITextView, allowing it to communicate changes back to SwiftUI.
final class Coordinator: NSObject, UITextViewDelegate {
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
