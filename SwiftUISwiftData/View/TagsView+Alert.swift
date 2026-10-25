//
//  TagsView+Alert.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import SwiftUI

extension TagsView {
    private var tagsToDelete: [Tag] {
        if editMode.isEditing {
            return selectedTags
        }

        guard let tagToDelete else {
            return []
        }
        return [tagToDelete]
    }

    var deleteAlert: Alert {
        .init(
            title: Text("Delete \(editMode.isEditing ? "selected tags" : "this tag")?"),
            primaryButton: .destructive(Text("Delete")) {
                guard !tagsToDelete.isEmpty else {
                    return
                }
                deleteTags(tagsToDelete)
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
}
