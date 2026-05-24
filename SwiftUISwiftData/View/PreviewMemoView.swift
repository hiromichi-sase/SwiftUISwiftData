//
//  PreviewMemoView.swift
//  SwiftUICoreData
//
//  Created by Hiromichi Sase on 2026/05/04.
//

import SwiftUI
import SwiftData

struct PreviewMemoView: View {
    var memo: Memo

    var body: some View {
        NavigationStack() {
            VStack(alignment: .leading) {
                Text(memo.content.isEmpty ? "(No Content)" : memo.content)
                    .foregroundStyle(memo.content.isEmpty ? .secondary : .primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()
        }
    }
}

#Preview {
    NavigationStack {
        let memo = Memo(title: "Sample Title", content: "Sample Content", createdAt: Date(), updatedAt: Date(), order: 0)
        PreviewMemoView(memo: memo)
    }
}
