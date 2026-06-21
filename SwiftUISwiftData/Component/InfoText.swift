//
//  InfoText.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/12.
//

import SwiftUI

struct InfoText {
    static func countView(content: String, textSelection: TextSelection? = nil) -> some View {
        HStack(spacing: .zero) {
            Text("Content Characters: \(content.count)")
                .font(.system(size: 8.0))
                .multilineTextAlignment(.leading)
            if !content.isEmpty {
                Spacer()
                    .frame(width: 8.0)
                Text("Content Line Numbers: \(content.components(separatedBy: .newlines).count)")
                    .font(.system(size: 8.0))
                    .multilineTextAlignment(.leading)
            }
            if let textSelection,
                let selection = selectedText(text: content, selection: textSelection),
                !selection.isEmpty
            {
                Spacer()
                    .frame(width: 8.0)
                Text("Selection Characters: \(selection.count)")
                    .font(.system(size: 8.0))
                    .multilineTextAlignment(.leading)
                Spacer()
                    .frame(width: 8.0)
                Text("Selection Line Numbers: \(selection.components(separatedBy: .newlines).count)")
                    .font(.system(size: 8.0))
                    .multilineTextAlignment(.leading)
            }
            Spacer()
        }
    }

    private static func selectedText(text: String, selection: TextSelection) -> String? {
        switch selection.indices {
            case .selection(let range):
                return String(text[range])
            case .multiSelection(let rangeSet):
                let selected = rangeSet.ranges.map { String(text[$0]) }.joined()
                return selected.isEmpty ? nil : selected
            @unknown default:
                fatalError("Unknown case of textSelection")
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

#Preview("countView") {
    InfoText.countView(content: "abcdefg")
}

#Preview("countView_selected") {
    let content = "abcdefg"
    if let first = content.firstIndex(of: "c"),
        let last = content.firstIndex(of: "f")
    {
        let textSelection = TextSelection(range: first ..< last)
        InfoText.countView(content: content, textSelection: textSelection)
    }
}

#Preview("dateView") {
    let memo = Memo(title: "Sample Title", content: "Sample Content", createdAt: Date(), updatedAt: Date(), order: .zero)
    InfoText.dateView(for: memo)
}
