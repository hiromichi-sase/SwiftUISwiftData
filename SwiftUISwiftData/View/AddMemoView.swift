//
//  AddMemoView.swift
//  SwiftUICoreData
//
//  Created by Hiromichi Sase on 2026/05/04.
//

import SwiftData
import SwiftUI

struct AddMemoView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var title: String = ""
    @State private var titleToStore: String = ""
    @State private var content: String = ""
    @State private var showConfirmationAlert = false
    @State private var showTitleSheet = false

    @State var path = NavigationPath()

    init() {
        titleToStore = title
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                TextView(text: $content, isEditable: true)
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
                        Text(titleToStore.isEmpty ? "(No Title)" : titleToStore)
                            .foregroundStyle(titleToStore.isEmpty ? .secondary : .primary)
                        Button("Rename", systemImage: "pencil") {
                            showTitleSheet = true
                        }
                    }
                }
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("Cancel", systemImage: "xmark") {
                        if !title.isEmpty || !content.isEmpty {
                            showConfirmationAlert = true
                        } else {
                            dismiss()
                        }
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Save", systemImage: "square.and.pencil") {
                        let order: Int
                        do {
                            order = try modelContext.fetchCount(FetchDescriptor<Memo>()) + 1
                        } catch {
                            order = 1
                        }
                        let memo = Memo(title: title, content: content, createdAt: Date(), updatedAt: Date(), order: order)
                        modelContext.insert(memo)
                        try? modelContext.save()

                        var transaction = Transaction(animation: .none)
                        transaction.disablesAnimations = sizeClass == .compact
                        withTransaction(transaction) {
                            dismiss()
                        }
                    }
                }
            }
            .sheet(isPresented: $showTitleSheet) {
                VStack(spacing: 16) {
                    Text("Input Title")
                        .font(.headline)

                    HStack(spacing: 0) {
                        TextField("Title", text: $title)
                            .textFieldStyle(.roundedBorder)
                            .frame(height: 44)
                            .padding(.horizontal)
                        Button("", systemImage: "x.circle") {
                            title = ""
                        }
                    }

                    HStack {
                        Button("Cancel", role: .cancel) {
                            title = titleToStore
                            showTitleSheet = false
                        }
                        Spacer()
                        Button("OK") {
                            titleToStore = title
                            showTitleSheet = false
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 20)
                .presentationDetents([.fraction(0.25)])
                .interactiveDismissDisabled()
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddMemoView()
    }
}
