//
//  ViewExtension.swift
//  SwiftUICoreData
//
//  Created by Hiromichi Sase on 2026/05/04.
//

import SwiftUI

extension View {
    func titleSheet(isPresented: Binding<Bool>, title: Binding<String>, titleToStore: Binding<String>) -> some View {
        self.sheet(isPresented: isPresented) {
            TitleSheetView(isPresented: isPresented, title: title, titleToStore: titleToStore)
        }
    }
}
