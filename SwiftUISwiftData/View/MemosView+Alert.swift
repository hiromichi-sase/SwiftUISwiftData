//
//  MemosView+Alert.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/05.
//

import SwiftUI

extension MemosView {
    private var memosToDelete: [Memo] {
        if editMode.isEditing {
            return selectedMemos
        }

        guard let memoToDelete else {
            return []
        }
        return [memoToDelete]
    }

    var deleteAlert: Alert {
        .init(
            title: Text("Delete \(editMode.isEditing ? "selected memos" : "this memo")?"),
            primaryButton: .destructive(Text("Delete")) {
                guard !memosToDelete.isEmpty else {
                    return
                }
                deleteMemos(memosToDelete)
            },
            secondaryButton: .cancel()
        )
    }

    var errorAlert: Alert {
        .init(
            title: Text("The Error occured."),
            message: Text(error?.localizedDescription ?? ""),
            dismissButton: .default(Text("OK"))
        )
    }

    var containsProtectedMemoAlert: Alert {
        .init(
            title: Text("Protected memos are contained in selected memos."),
            message: Text(error?.localizedDescription ?? ""),
            dismissButton: .default(Text("OK"))
        )
    }
}
