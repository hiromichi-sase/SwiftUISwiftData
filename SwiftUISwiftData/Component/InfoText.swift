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
            info("Content: \(content.count.nounText(for: .character))")
            if !content.isEmpty {
                info(", \(content.components(separatedBy: .newlines).count.nounText(for: .line))")
            }
            if let textSelection,
                let selection = selectedText(text: content, selection: textSelection),
                !selection.isEmpty
            {
                Spacer()
                    .frame(width: 8.0)
                info("Selection: \(selection.count.nounText(for: .character))")
                info(", \(selection.components(separatedBy: .newlines).count.nounText(for: .line))")
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
        dateView(createdAt: memo.createdAt, updatedAt: memo.updatedAt)
    }

    static func dateView(for tag: Tag) -> some View {
        dateView(createdAt: tag.createdAt, updatedAt: tag.updatedAt)
    }

    private static func dateView(createdAt: Date, updatedAt: Date) -> some View {
        HStack(spacing: .zero) {
            info("Created at: \(createdAt.dateString)")
            Spacer()
                .frame(width: 8.0)
            info("Updated at: \(updatedAt.dateString)")
            Spacer()
        }
    }

    private static func info(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 8.0))
            .multilineTextAlignment(.leading)
    }
}

#Preview("countView_no_content") {
    let content = ""
    let textSelection: TextSelection? = nil
    InfoText.countView(content: content, textSelection: textSelection)
}

#Preview("countView_not_selected") {
    let content = "abcdefg"
    let textSelection: TextSelection? = nil
    InfoText.countView(content: content, textSelection: textSelection)
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

#Preview("dateView_Memo") {
    let memo = Memo(title: "Sample Title", content: "Sample Content", createdAt: Date(), updatedAt: Date(), order: .zero)
    InfoText.dateView(for: memo)
}

#Preview("dateView_Tag") {
    let tag = Tag(title: "Sample Title", color: "#000000", createdAt: Date(), updatedAt: Date(), order: .zero)
    InfoText.dateView(for: tag)
}
