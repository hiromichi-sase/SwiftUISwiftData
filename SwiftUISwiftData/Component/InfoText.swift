//
//  InfoText.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/12.
//

import SwiftUI

struct InfoText {
    static func countView(content: String) -> some View {
        HStack(spacing: .zero) {
            Text("Content Characters: \(content.count)")
                .font(.system(size: 8.0))
                .multilineTextAlignment(.leading)
            Spacer()
                .frame(width: 8.0)
            Text("Content Line Numbers: \(content.components(separatedBy: .newlines).count)")
                .font(.system(size: 8.0))
                .multilineTextAlignment(.leading)
            Spacer()
        }
    }

    static func dateView(for memo: Memo) -> some View {
        HStack(spacing: .zero) {
            Text("Created at: \(memo.createdAt.formatted(date: .complete, time: .standard))")
                .font(.system(size: 8.0))
                .multilineTextAlignment(.leading)
            Spacer()
                .frame(width: 8.0)
            Text("Updated at: \(memo.updatedAt.formatted(date: .complete, time: .standard))")
                .font(.system(size: 8.0))
                .multilineTextAlignment(.leading)
            Spacer()
        }
    }
}
