//
//  TextView.swift
//  SwiftUICoreData
//
//  Created by Hiromichi Sase on 2026/05/31.
//

import SwiftUI

struct Toast: ViewModifier {
    @Binding var message: String

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                toastView
                    .padding(.top, 10)
            }
    }

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
