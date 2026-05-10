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

    private struct MemoRow: View {
        let memo: Memo
        let onTap: (UUID) -> Void

        var body: some View {
            Button(action: {
                onTap(memo.id)
            }) {
                HStack {
                    Text(memo.title)
                    Spacer()
                }
            }
            .foregroundStyle(.primary)
            .padding()
            .contentShape(Rectangle())
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            List(selection: $selection) {
                ForEach(memos) { memo in
                    if editMode == .inactive {
                        inactiveRow(for: memo)
                    } else {
                        activeRow(for: memo)
                    }
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
            .navigationTitle(editMode == .active ? Text("") : Text("Memos"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    toolbarItemTopBarLeading
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    toolbarItemTopBarTrailing
                }
            }
            .environment(\.editMode, $editMode)
        }
    }

    @ViewBuilder
    private func activeRow(for memo: Memo) -> some View {
        MemoRow(memo: memo) { id in
            toggleSelection(for: id)
        }
        .listRowInsets(.init())
        .moveDisabled(false)
        .listRowBackground(Color(uiColor: .secondarySystemGroupedBackground))
    }

    @ViewBuilder
    private func inactiveRow(for memo: Memo) -> some View {
        MemoRow(memo: memo) { _ in
            memoToPush = memo
        }
        .contextMenu {
            Button("Edit", systemImage: "pencil") {
                memoToPush = memo
            }
            Button("Delete", systemImage: "trash", role: .destructive) {
                memoToDelete = memo
            }
        } preview: {
            PreviewMemoView(memo: memo)
        }
        .listRowInsets(.init())
        .moveDisabled(true)
    }

    @ViewBuilder
    private var toolbarItemTopBarLeading: some View {
        if editMode == .inactive {
            if !memos.isEmpty {
                Button("Edit", systemImage: "pencil") {
                    editMode = .active
                }
            }
        } else {
            Button("Done", systemImage: "checkmark") {
                editMode = .inactive
            }
        }
    }

    @ViewBuilder
    private var toolbarItemTopBarTrailing: some View {
        if editMode == .inactive {
            NavigationLink {
                AddMemoView()
            } label: {
                Image(systemName: "plus.circle")
            }
        } else {
            Menu("Menu", systemImage: "ellipsis.circle") {
                Button("Select All", systemImage: "checkmark.circle") {
                    selection = Set(memos.map { $0.id })
                }
                .disabled(selection.count == memos.count)
                Button("Deselect All", systemImage: "circle") {
                    selection.removeAll()
                }
                .disabled(selection.count == .zero)
            }
            Button("Delete", systemImage: "trash") {
                showDeleteSelectionAlert = true
            }
            .disabled(selection.isEmpty)
        }
    }

    private func toggleSelection(for id: UUID) {
        if selection.contains(id) {
            selection.remove(id)
        } else {
            selection.insert(id)
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
