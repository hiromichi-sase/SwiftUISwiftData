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
    @Query(sort: [SortDescriptor(\Memo.order)]) private var memos: [Memo]

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
                        HStack {
                            Text(memo.title)
                            Spacer()
                        }
                        .padding()
                    }
                    .listRowInsets(.init())
                    .buttonStyle(ListItemButtonStyle(editMode: editMode))
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
                    .moveDisabled(!editMode.isEditing)
                }
                .onMove(perform: moveMemo)
                .onDelete(perform: deleteMemo)
                .alert(item: $memoToDelete) { memo in
                    Alert(title: Text("Delete this memo?"),
                          primaryButton: .destructive(Text("Delete")) {
                        modelContext.delete(memo)
                        try? modelContext.save()
                        moveAllMemos()
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
                    if editMode == .inactive {
                        NavigationLink {
                            AddMemoView()
                        } label: {
                            Text("Add")
                        }
                    }
                }
            }
            .environment(\.editMode, $editMode)
        }
    }

    private func deleteMemo(offsets: IndexSet) {
        guard let first = offsets.first else { return }
        memoToDelete = memos[first]
    }

    private func moveMemo(from source: IndexSet, to destination: Int) {
        guard editMode == .active else { return }

        var orderedMemos = memos.sorted(by: { $0.order < $1.order })
        orderedMemos.move(fromOffsets: source, toOffset: destination)
        for (index, memo) in orderedMemos.enumerated() {
            if let existingMemo = memos.first(where: { $0.id == memo.id }) {
                existingMemo.order = index + 1
            }
        }
        try? modelContext.save()
    }

    private func moveAllMemos() {
        for (index, memo) in memos.enumerated() {
            memo.order = index + 1
        }
        try? modelContext.save()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Memo.self, inMemory: true)
}
