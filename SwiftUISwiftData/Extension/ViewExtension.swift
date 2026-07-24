//
//  ViewExtension.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/24.
//

import SwiftUI

struct ViewDidLoadModifier: ViewModifier {
    @State
    private var didLoad = false
    private let action: (() -> Void)?

    init(perform action: (() -> Void)? = nil) {
        self.action = action
    }

    func body(content: Content) -> some View {
        content.onAppear {
            if didLoad == false {
                didLoad = true
                action?()
            }
        }
    }
}

extension View {
    func onLoad(perform action: (() -> Void)? = nil) -> some View {
        modifier(ViewDidLoadModifier(perform: action))
    }
}
