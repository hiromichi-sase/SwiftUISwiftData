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

    private var memo: Memo

    @State private var title: String
    @State private var content: String
    @State private var showConfirmationAlert = false

    @State var path = NavigationPath()
    @State var disabled: Bool

    init(memo: Memo, disabled: Bool) {
        self.memo = memo
        self._title = State(initialValue: memo.title)
        self._content = State(initialValue: memo.content)
        self._disabled = State(initialValue: disabled)
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                TextView(text: $content, isEditable: .constant(!disabled))
                    .border(disabled ? .clear : .primary)
            }
            .padding()
            .onReceive(didSavePublisher) { _ in
                guard disabled else { return }
                title = memo.title
                content = memo.content
            }
            .alert(isPresented: $showConfirmationAlert) {
                Alert(
                    title: Text("Discard changes?"),
                    primaryButton: .destructive(Text("Discard")) {
                        title = memo.title
                        content = memo.content
                        disabled = true
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .navigationTitle($title, disabled: disabled)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(!disabled)
        .toolbar {
            if !disabled {
                ToolbarItem(placement: .principal) {
                    TextField("(Input Title)", text: $title)
                        .multilineTextAlignment(.center)
                        .background(.secondary)
                }
            }
            ToolbarItemGroup(placement: .topBarLeading) {
                if !disabled {
                    Button("Cancel", systemImage: "xmark") {
                        guard !disabled else { return }
                        if memoUpdated {
                            showConfirmationAlert = true
                        } else {
                            disabled = true
                        }
                    }
                }
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                if disabled {
                    Button("Edit", systemImage: "pencil") {
                        disabled = false
                    }
                } else {
                    Button("Save", systemImage: "square.and.pencil") {
                        guard !disabled && memoUpdated else { return }
                        memo.title = title
                        memo.content = content
                        memo.updatedAt = Date()
                        try? modelContext.save()
                        disabled = true
                    }
                    .disabled(!memoUpdated)
                }

            }
        }
    }

    private var memoUpdated: Bool {
        memo.title != title || memo.content != content
    }

    private var didSavePublisher: NotificationCenter.Publisher {
        NotificationCenter.default
            .publisher(for: ModelContext.willSave, object: modelContext)
    }
}

struct Disabled_True_Previews: PreviewProvider {
    static var previews: some View {
        let memo = Memo(title: "Sample Title", content: "Sample Content", createdAt: Date(), updatedAt: Date(), order: 0)
        return NavigationStack {
            EditMemoView(memo: memo, disabled: true)
        }
    }
}

struct Disabled_False_Previews: PreviewProvider {
    static var previews: some View {
        let memo = Memo(title: "Sample Title", content: "Sample Content", createdAt: Date(), updatedAt: Date(), order: 0)
        return NavigationStack {
            EditMemoView(memo: memo, disabled: false)
        }
    }
}
