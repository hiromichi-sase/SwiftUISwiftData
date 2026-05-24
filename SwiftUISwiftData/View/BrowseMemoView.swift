//
//  BrowseMemoView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/05/23.
//

import SwiftData
import SwiftUI

struct BrowseMemoView: View {
    @Environment(\.modelContext) private var modelContext

    private var memo: Memo
    @State private var openEditMemoView = false

    @State private var title: String
    @State private var content: String
    @State private var showingEditMemo = false

    @State var path = NavigationPath()

    init(memo: Memo, openEditMemoView: Bool = false) {
        self.memo = memo
        self._title = State(initialValue: memo.title)
        self._content = State(initialValue: memo.content)
        self._openEditMemoView = State(initialValue: openEditMemoView)
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                BrowseTextView(text: $content)
                    .border(.clear)
            }
            .padding()
            .onAppear {
                if openEditMemoView {
                    showingEditMemo = true
                    openEditMemoView = false
                }
            }
            .onReceive(willSavePublisher) { _ in
                title = memo.title
                content = memo.content
            }
            .fullScreenCover(isPresented: $showingEditMemo) {
                EditMemoView(memo: memo)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        TitleText(title)
                        if !title.isEmpty {
                            Button("Copy", systemImage: "doc.on.doc") {
                                UIPasteboard.general.string = $title.wrappedValue
                            }
                        }
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Edit", systemImage: "pencil") {
                        showingEditMemo = true
                    }
                }
            }
        }
    }

    private var memoUpdated: Bool {
        memo.title != title || memo.content != content
    }

    private var willSavePublisher: NotificationCenter.Publisher {
        NotificationCenter.default
            .publisher(for: ModelContext.willSave, object: modelContext)
    }
}

#Preview {
    NavigationStack {
        let memo = Memo(title: "Sample Title", content: "Sample Content", createdAt: Date(), updatedAt: Date(), order: 0)
        BrowseMemoView(memo: memo)
    }
}
