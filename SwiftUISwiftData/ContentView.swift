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

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(memos) { memo in
                    NavigationLink {
                        Text("Memo at \(memo.createdAt, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(memo.createdAt, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteMemos)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addMemo) {
                        Label("Add Memo", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select a memo")
        }
    }

    private func addMemo() {
        withAnimation {
            let newMemo = Memo(title: "", content: "", createdAt: Date(), updatedAt: Date(), order: memos.count + 1)
            modelContext.insert(newMemo)
        }
    }

    private func deleteMemos(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(memos[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Memo.self, inMemory: true)
}
