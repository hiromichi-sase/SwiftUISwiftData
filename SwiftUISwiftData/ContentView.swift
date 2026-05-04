//
//  ContentView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/05/04.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var memos: [Memo]

    @State private var editMode: EditMode = .inactive
    @State private var memoToDelete: Memo?
    @State private var memoToPush: Memo?
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(memos) { memo in
                    Button {
                        if editMode == .inactive {
                            memoToPush = memo
                        }
                    } label: {
                        Text(memo.title)
                    }
                    .tint(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .contextMenu {
                        if editMode == .inactive {
                            Button("Edit", systemImage: "pencil") {
                                memoToPush = memo
                            }
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                memoToDelete = memo
                            }
                        }
                    } preview: {
                        if editMode == .inactive {
                            PreviewMemoView(memo: memo)
                        }
                    }
                }
                .onDelete(perform: deleteMemos)
                .alert(item: $memoToDelete) { memo in
                    Alert(title: Text("Delete this memo?"),
                          primaryButton: .destructive(Text("Delete")) {
                        deleteMemo(memo: memo)
                    }, secondaryButton: .cancel())
                }
            }
            .navigationDestination(item: $memoToPush) { memo in
                EditMemoView(memo: memo, disabled: true)
            }
            .navigationTitle(Text("Memos"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    EditButton()
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    NavigationLink {
                        AddMemoView()
                    } label: {
                        Text("Add")
                    }
                }
            }
            .environment(\.editMode, $editMode)
        }
    }

    private func deleteMemo(memo: Memo) {
        modelContext.delete(memo)
        try? modelContext.save()
    }

    private func deleteMemos(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(memos[index])
            }
            try? modelContext.save()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Memo.self, inMemory: true)
}
