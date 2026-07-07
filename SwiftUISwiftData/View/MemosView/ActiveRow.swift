//
//  ActiveRow.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/23.
//

import SwiftUI

struct ActiveRow: View {
    let memo: Memo
    let titleLineLimit: Int
    let titleFontSize: Float
    let titleLineSpacing: Float
    let showInfo: Bool

    var body: some View {
        VStack(spacing: .zero) {
            HStack {
                RowText(
                    memo: memo,
                    titleLineLimit: titleLineLimit,
                    titleFontSize: titleFontSize,
                    titleLineSpacing: titleLineSpacing
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                if memo.protected {
                    Image(systemName: "lock.fill")
                }
            }
            if showInfo {
                VStack(alignment: .leading, spacing: .zero) {
                    InfoText.countView(content: memo.content)
                    InfoText.dateView(for: memo)
                }
                .padding(.top)
            }
        }
    }
}
