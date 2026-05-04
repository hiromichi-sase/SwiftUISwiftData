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
                Text(memo.content)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()
        }
    }
}

struct PreviewMemoView_Previews: PreviewProvider {
    static var previews: some View {
        let memo = Memo(title: "Sample Title", content: "Sample Content", createdAt: Date(), updatedAt: Date(), order: 0)
        return NavigationStack {
            PreviewMemoView(memo: memo)
        }
    }
}
