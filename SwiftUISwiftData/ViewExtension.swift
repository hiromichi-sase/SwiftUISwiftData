//
//  ViewExtension.swift
//  SwiftUICoreData
//
//  Created by Hiromichi Sase on 2026/05/04.
//

import SwiftUI

extension View {
    @ViewBuilder
    func navigationTitle(_ title: Binding<String>, disabled: Bool) -> some View {
        if disabled {
            self.navigationTitle(Text(title.wrappedValue))
        } else {
            self.navigationTitle(title)
        }
    }
}
