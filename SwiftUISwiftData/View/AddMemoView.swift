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
    @State private var content: String = ""
    @State private var showConfirmationAlert = false

    @State var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                TextView(text: $content, isEditable: .constant(true))
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
                    TextField("Title", text: $title)
                        .multilineTextAlignment(.center)
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
        }
    }
}

#Preview {
    NavigationStack {
        AddMemoView()
    }
}
