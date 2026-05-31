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

    @State private var memo: Memo?

    @State private var title: String
    @State private var titleToStore: String = ""
    @State private var content: String
    @State private var showConfirmationAlert = false
    @State private var showTitleView = false
    @State private var toastMessage = ""

    @FocusState private var textViewFocus: Bool
    @FocusState private var textFieldFocus: Bool

    @State var path = NavigationPath()

    init(memo: Memo? = nil) {
        self.memo = memo
        self._title = State(initialValue: memo?.title ?? "")
        self._content = State(initialValue: memo?.content ?? "")
        self._titleToStore = State(initialValue: memo?.title ?? "")
        self._toastMessage = State(initialValue: "")
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 8) {
                if showTitleView {
                    titleView
                }
                contentView
            }
            .padding(.top, 0)
            .padding([.horizontal, .bottom], 16)
            .onAppear {
                textViewFocus = true
            }
            .alert(isPresented: $showConfirmationAlert) {
                Alert(
                    title: Text("Discard changes?"),
                    primaryButton: .destructive(Text("Discard")) {
                        dismiss()
                    },
                    secondaryButton: .cancel()
                )
            }
            .navigationTitle(titleToStore)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel", systemImage: "xmark") {
                        if memoUpdated {
                            showConfirmationAlert = true
                        } else {
                            dismiss()
                        }
                    }
                    .disabled(showTitleView)
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Rename", systemImage: "rectangle.and.pencil.and.ellipsis") {
                        showTitleView = true
                        textFieldFocus = true
                    }
                    .disabled(showTitleView)
                    Button("Save", systemImage: "square.and.pencil") {
                        guard memoUpdated else { return }

                        if let memo {
                            memo.title = title
                            memo.content = content
                            memo.updatedAt = Date()
                        } else {
                            let order: Int
                            do {
                                order = try modelContext.fetchCount(FetchDescriptor<Memo>()) + 1
                            } catch {
                                order = 1
                            }
                            let memo = Memo(title: title, content: content, createdAt: Date(), updatedAt: Date(), order: order)
                            modelContext.insert(memo)
                            self.memo = memo
                        }

                        try? modelContext.save()
                        toastMessage = "Successfully saved!"
                    }
                    .disabled(!memoUpdated || showTitleView)
                }
            }
            .toast(message: $toastMessage)
        }
    }

    private var titleView: some View {
        HStack(spacing: 8) {
            Button("", systemImage: "xmark") {
                title = titleToStore
                showTitleView = false
            }
            TextField("Title", text: $title)
                .padding(6)
                .border(.primary)
                .focused($textFieldFocus)
                .submitLabel(.done)
                .onSubmit {
                    titleToStore = title
                    showTitleView = false
                }
            Button("", systemImage: "eraser") {
                title = ""
            }
        }
    }

    private var contentView: some View {
        TextView(text: $content, isEditable: !showTitleView)
            .border(showTitleView ? .secondary : .primary)
            .focused($textViewFocus)
            .disabled(showTitleView)
            .overlay(alignment: .topLeading) {
                if content.isEmpty {
                    Text("Input Content")
                        .allowsHitTesting(false)
                        .foregroundColor(Color(uiColor: .placeholderText))
                        .padding(6)
                }
            }
    }

    private var memoUpdated: Bool {
        if let memo {
            memo.title != titleToStore || memo.content != content
        } else {
            !titleToStore.isEmpty || !content.isEmpty
        }
    }
}

#Preview {
    NavigationStack {
        let memo = Memo(title: "Sample Title", content: "Sample Content", createdAt: Date(), updatedAt: Date(), order: 0)
        EditMemoView(memo: memo)
    }
}
