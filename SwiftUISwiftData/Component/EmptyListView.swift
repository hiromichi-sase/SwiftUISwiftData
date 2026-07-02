//
//  EmptyListView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/01.
//

import SwiftUI

struct EmptyListView: View {
    let message: String

    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "tray")
                .font(.largeTitle)
                .padding(.bottom)
            Text(message)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyListView(message: "No Data found")
}
