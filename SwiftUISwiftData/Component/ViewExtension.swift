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
            VStack(spacing: 16) {
                Text("Input Title")
                    .font(.headline)

                HStack(spacing: 0) {
                    TextField("Title", text: title)
                        .textFieldStyle(.roundedBorder)
                        .frame(height: 44)
                        .padding(.horizontal)
                    Button("", systemImage: "x.circle") {
                        title.wrappedValue = ""
                    }
                }

                HStack {
                    Button("Cancel", role: .cancel) {
                        title.wrappedValue = titleToStore.wrappedValue
                        isPresented.wrappedValue = false
                    }
                    Spacer()
                    Button("OK") {
                        titleToStore.wrappedValue = title.wrappedValue
                        isPresented.wrappedValue = false
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 20)
            .presentationDetents([.fraction(0.25)])
            .interactiveDismissDisabled()
        }
    }
}
