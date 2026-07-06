//
//  InactiveRow.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/23.
//

import SwiftUI

struct InactiveRow: View {
    let memo: Memo
    let titleLineLimit: Int
    let titleFontSize: Float
    let titleLineSpacing: Float
    let showInfo: Bool
    let searchWords: [String]

    var body: some View {
        VStack(spacing: .zero) {
            HStack {
                RowText(
                    memo: memo,
                    titleLineLimit: titleLineLimit,
                    titleFontSize: titleFontSize,
                    titleLineSpacing: titleLineSpacing,
                    searchWords: searchWords
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                if memo.protected {
                    Image(systemName: "lock.fill")
                        .padding(.trailing)
                }
            }
            if showInfo {
                VStack(alignment: .leading, spacing: .zero) {
                    InfoText.countView(content: memo.content)
                    InfoText.dateView(for: memo)
                }
                .padding(.bottom)
                .padding(.horizontal)
            }
        }
    }
}
