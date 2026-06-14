//
//  Toast.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/05/31.
//

import SwiftUI

/// A view modifier that displays a toast message at the top of the screen when the message is not empty.
///
/// The toast automatically disappears after 2 seconds or when tapped.
struct Toast: ViewModifier {
    /// The message to be displayed in the toast.
    ///
    /// When this string is empty, the toast will not be shown.
    @Binding var message: String

    /// Defines the content and behavior of the view modifier.
    ///
    /// It overlays the toast view at the top of the content when the message is not empty.
    /// - Parameter content: The original content view to which the toast will be added as an overlay.
    /// - Returns: A modified view that includes the toast overlay when the message is not empty.
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                toastView
                    .padding(.top, 10)
            }
    }

    /// A private computed property that defines the view for the toast message.
    ///
    /// It displays the message in a styled text view with a background and border. The toast disappears after 2 seconds or when tapped.
    private var toastView: some View {
        VStack {
            if !message.isEmpty {
                Text(message)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 18)
                    .background(.gray.opacity(0.8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 5)
                            .fill(.secondary)
                    }
                    .mask {
                        RoundedRectangle(cornerRadius: 10)
                    }
                    .onTapGesture {
                        message = ""
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            message = ""
                        }
                    }
                    .transition(.opacity)
            }
        }
    }
}

extension View {
    func toast(message: Binding<String>) -> some View {
        self.modifier(Toast(message: message))
    }
}
