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

    @State private var selection: Set<UUID> = []
    @State private var showDeleteSelectionAlert = false

    var body: some View {
        NavigationStack(path: $path) {
            List(selection: $selection) {
                ForEach(memos) { memo in
                    let _memo = memo
                    HStack {
                        Text(_memo.title)
                        Spacer()
                    }
                    .padding()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if editMode == .inactive {
                            memoToPush = _memo
                        } else {
                            if selection.contains(_memo.id) {
                                selection.remove(_memo.id)
                            } else {
                                selection.insert(_memo.id)
                            }
                        }
                    }
                    .contextMenu {
                        if editMode == .inactive {
                            Button("Edit", systemImage: "pencil") {
                                memoToPush = _memo
                            }
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                memoToDelete = _memo
                            }
                        }
                    } preview: {
                        if editMode == .inactive {
                            PreviewMemoView(memo: _memo)
                        }
                    }
                    .listRowInsets(.init())
                    .moveDisabled(!editMode.isEditing)
                }
                .onMove(perform: moveMemo)
            }
            .onChange(of: memos) { _, newMemos in
                if editMode == .active,
                   newMemos.isEmpty {
                    editMode = .inactive
                }
            }
            .alert(item: $memoToDelete) { memo in
                Alert(
                    title: Text("Delete this memo?"),
                    primaryButton: .destructive(Text("Delete")) {
                        deleteMemos([memo])
                    },
                    secondaryButton: .cancel()
                )
            }
            .alert("Delete selected memos?", isPresented: $showDeleteSelectionAlert) {
                Button("Delete", role: .destructive) {
                    deleteMemos(selectedMemos)
                }
                Button("Cancel", role: .cancel) {}
            }
            .navigationDestination(item: $memoToPush) { memo in
                EditMemoView(memo: memo, disabled: true)
            }
            .navigationTitle(Text("Memos"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    if !memos.isEmpty {
                        EditButton()
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if editMode == .inactive {
                        NavigationLink {
                            AddMemoView()
                        } label: {
                            Text("Add")
                        }
                    } else {
                        Button(role: .destructive) {
                            showDeleteSelectionAlert = true
                        } label: {
                            Text("Delete")
                        }
                        .disabled(selection.isEmpty)
                    }
                }
            }
            .environment(\.editMode, $editMode)
        }
    }

    private var selectedMemos: [Memo] {
        memos.filter { selection.contains($0.id) }
    }

    private func deleteMemos(_ memos: [Memo]) {
        for memo in memos {
            modelContext.delete(memo)
        }
        try? modelContext.save()
        selection.removeAll()
        moveAllMemos()
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
