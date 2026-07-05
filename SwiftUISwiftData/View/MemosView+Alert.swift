//
//  MemosView+Alert.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/05.
//

import SwiftUI

extension MemosView {
    var deleteAlert: Alert {
        .init(
            title: Text("Delete \(editMode.isEditing ? "selected memos" : "this memo")?"),
            primaryButton: .destructive(Text("Delete")) {
                if editMode.isEditing {
                    guard !selectedMemos.isEmpty else { return }
                    deleteMemos(selectedMemos)
                }
                else {
                    guard let memoToDelete = memoToDelete else { return }
                    deleteMemos([memoToDelete])
                }
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

    var protectAlert: Alert {
        .init(
            title: Text("Protect selected memos?"),
            primaryButton: .default(Text("Protect")) {
                guard !selectedMemos.isEmpty else { return }
                Task {
                    await protect(selectedMemos)
                }
            },
            secondaryButton: .cancel()
        )
    }

    var unprotectAlert: Alert {
        .init(
            title: Text("Unprotect selected memos?"),
            primaryButton: .default(Text("Unprotect")) {
                guard !selectedMemos.isEmpty else { return }
                Task {
                    await unprotect(selectedMemos)
                }
            },
            secondaryButton: .cancel()
        )
    }
}
