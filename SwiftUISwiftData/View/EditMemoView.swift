//
//  EditMemoView.swift
//  SwiftUICoreData
//
//  Created by Hiromichi Sase on 2026/05/04.
//

import SwiftData
import SwiftUI

struct EditMemoView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private var memo: Memo

    @State private var title: String
    @State private var titleToStore: String = ""
    @State private var content: String
    @State private var showConfirmationAlert = false
    @State private var showTitleSheet = false

    @State var path = NavigationPath()

    init(memo: Memo) {
        self.memo = memo
        self._title = State(initialValue: memo.title)
        self._content = State(initialValue: memo.content)
        self._titleToStore = State(initialValue: memo.title)
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                TextView(text: $content)
                    .border(.primary)
            }
            .padding()
            .alert(isPresented: $showConfirmationAlert) {
                Alert(
                    title: Text("Discard changes?"),
                    primaryButton: .destructive(Text("Discard")) {
                        dismiss()
                    },
                    secondaryButton: .cancel()
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        TitleText(titleToStore)
                        Button("Rename", systemImage: "pencil") {
                            showTitleSheet = true
                        }
                    }
                }
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel", systemImage: "xmark") {
                        if memoUpdated {
                            showConfirmationAlert = true
                        } else {
                            dismiss()
                        }
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Save", systemImage: "square.and.pencil") {
                        guard memoUpdated else { return }
                        memo.title = title
                        memo.content = content
                        memo.updatedAt = Date()
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(!memoUpdated)
                }
            }
            .titleSheet(isPresented: $showTitleSheet, title: $title, titleToStore: $titleToStore)
        }
    }

    private var memoUpdated: Bool {
        memo.title != titleToStore || memo.content != content
    }
}

#Preview {
    NavigationStack {
        let memo = Memo(title: "Sample Title", content: "Sample Content", createdAt: Date(), updatedAt: Date(), order: 0)
        return NavigationStack {
            EditMemoView(memo: memo)
        }
    }
}
