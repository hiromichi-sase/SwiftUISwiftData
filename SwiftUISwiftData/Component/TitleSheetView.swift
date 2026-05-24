//
//  TitleSheetView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/05/24.
//

import SwiftUI

struct TitleSheetView: View {
    @Binding var isPresented: Bool
    @Binding var title: String
    @Binding var titleToStore: String
    @FocusState private var textFieldFocus: Bool

    var body: some View {
        VStack(spacing: 16) {
            Text("Input Title")
                .font(.headline)

            HStack(spacing: 0) {
                TextField("Title", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .frame(height: 44)
                    .padding(.horizontal)
                    .focused($textFieldFocus)
                Button("", systemImage: "x.circle") {
                    title = ""
                }
            }

            HStack {
                Button("Cancel", role: .cancel) {
                    title = titleToStore
                    isPresented = false
                }
                Spacer()
                Button("OK") {
                    titleToStore = title
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 20)
        .presentationDetents([.fraction(0.25)])
        .interactiveDismissDisabled()
        .onAppear {
            textFieldFocus = true
        }
    }
}

#Preview {
    TitleSheetView(isPresented: .constant(true), title: .constant(""), titleToStore: .constant(""))
}
