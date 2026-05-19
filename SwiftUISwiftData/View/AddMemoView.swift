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

    @State private var title: String = "(Title)"
    @State private var content: String = ""

    @State var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                TextView(text: $content, isEditable: .constant(true))
                    .border(.primary)
            }
            .padding()
            .navigationTitle($title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
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
