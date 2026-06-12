//
//  TextView.swift
//  SwiftUISwiftData
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
    var hasLink: Bool
    var contentFontSize: Float
    var contentLineSpacing: Float

    /// Initializes a new TextView with the specified parameters.
    /// - Parameters:
    ///   - text: The text content of the TextView, bound to a SwiftUI state variable.
    ///   - isEditable: A flag indicating whether the TextView is editable or read-only.
    ///   - defaultText: An optional default text to display when the TextView is empty and not editable. display when the TextView is empty and not editable.
    ///   - hasLink: An optional default flag indicating where the TextView has links.
    init(
        text: Binding<String>,
        isEditable: Bool,
        defaultText: String? = nil,
        hasLink: Bool = false,
        contentFontSize: Float = .zero,
        contentLineSpacing: Float = .zero
    ) {
        self._text = text
        self.isEditable = isEditable
        self.defaultText = defaultText
        self.hasLink = hasLink
        self.contentFontSize = contentFontSize
        self.contentLineSpacing = contentLineSpacing
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
        textView.isEditable = isEditable
        textView.dataDetectorTypes = hasLink ? .all : []
        textView.font = UIFont.systemFont(ofSize: CGFloat(contentFontSize))
        textView.attributedText = attributedText

        return textView
    }

    // swiftlint:disable unused_parameter
    /// Updates the UITextView instance with the latest text content and configuration whenever the SwiftUI state changes.
    /// - Parameters:
    ///   - uiView: The UITextView instance to be updated.
    ///   - context: The context for the UIView.
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedText

        if uiView.text != text {
            uiView.text = text
        }

        if let defaultText, text.isEmpty {
            uiView.text = defaultText
        }

        uiView.textColor = !text.isEmpty ? .label : .secondaryLabel
        uiView.dataDetectorTypes = hasLink ? .all : []
    }
    // swiftlint:enable unused_parameter

    private var attributedText: NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = CGFloat(contentLineSpacing)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: CGFloat(contentFontSize)),
            .paragraphStyle: paragraphStyle
        ]
        return NSAttributedString(
            string: text,
            attributes: attributes
        )
    }
}
