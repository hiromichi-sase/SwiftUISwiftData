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
    @State private var selectedMemoId: UUID?
    @State private var selection: Set<UUID> = []
    @State private var showDeleteSelectionAlert = false
    @State private var showingAddMemo = false
    @State private var scrollViewProxy: ScrollViewProxy?
    @State private var editModeViewDisabled: Bool = false

    private struct MemoRow: View {
        let memo: Memo
        let onTap: (Memo) -> Void

        var body: some View {
            Button(action: {
                onTap(memo)
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

    var list: some View {
        ScrollViewReader { proxy in
            VStack {
                if editMode == .active {
                    List(selection: $selection) {
                        ForEach(memos) { memo in
                            activeRow(for: memo)
                                .id(memo.id)
                                .tag(memo.id)
                        }
                        .onMove(perform: moveMemo)
                    }
                } else {
                    List(selection: $selectedMemoId) {
                        ForEach(memos) { memo in
                            inactiveRow(for: memo)
                                .id(memo.id)
                                .tag(memo.id)
                        }
                    }
                }
            }
            .onAppear {
                scrollViewProxy = proxy
            }
        }
    }

    var body: some View {
        NavigationSplitView {
            list
            .onChange(of: memos) { oldMemos, newMemos in
                onChange(oldMemos: oldMemos, newMemos: newMemos)
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
            .navigationTitle(navigationTitle)
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
            .fullScreenCover(isPresented: $showingAddMemo) {
                AddMemoView()
            }
        } detail: {
            if editMode == .inactive {
                if let id = selectedMemoId,
                   let memo = memos.first(where: { $0.id == id }) {
                    EditMemoView(memo: memo, disabled: editModeViewDisabled)
                        .modelContext(modelContext)
                        .id(memo.id)
                } else {
                    Text("Select a memo")
                }
            } else {
                Text("Select memos to edit or delete")
            }
        }
    }

    private var navigationTitle: String {
        "Memos (\(editMode == .active ? "\(selection.count)/" : "")\(memos.count))"
    }

    @ViewBuilder
    private func activeRow(for memo: Memo) -> some View {
        MemoRow(memo: memo) { memo in
            toggleSelection(for: memo.id)
        }
        .listRowInsets(.init())
        .moveDisabled(false)
        .listRowBackground(Color(uiColor: .secondarySystemGroupedBackground))
    }

    @ViewBuilder
    private func inactiveRow(for memo: Memo) -> some View {
        HStack {
            Text(memo.title)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            editModeViewDisabled = true
            selectedMemoId = memo.id
        }
        .contextMenu {
            Button("Edit", systemImage: "pencil") {
                editModeViewDisabled = false
                selectedMemoId = memo.id
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
                    selectedMemoId = nil
                    editMode = .active
                }
            }
        } else {
            Button("Done", systemImage: "checkmark") {
                selection.removeAll()
                editMode = .inactive
            }
        }
    }

    @ViewBuilder
    private var toolbarItemTopBarTrailing: some View {
        if editMode == .inactive {
            Button("Add", systemImage: "plus.circle") {
                showingAddMemo = true
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
            if selectedMemoId == memo.id {
                selectedMemoId = nil
            }
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

    private func onChange(oldMemos: [Memo], newMemos: [Memo]) {
        switch editMode {
        case .active:
            if newMemos.isEmpty {
                selection.removeAll()
                editMode = .inactive
            }
        case .inactive:
            if let newMemo = newMemos.first(where: { !oldMemos.contains($0) }) {
                DispatchQueue.main.async {
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) {
                        self.selection.removeAll()
                        self.editModeViewDisabled = true
                        self.selectedMemoId = newMemo.id
                        if let proxy = self.scrollViewProxy {
                            proxy.scrollTo(newMemo.id, anchor: .center)
                        }
                    }
                }
            }
        default:
            break
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Memo.self, inMemory: true)
}
