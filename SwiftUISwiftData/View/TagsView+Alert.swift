//
//  TagsView+Alert.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import SwiftUI

extension TagsView {
    var deleteAlert: Alert {
        .init(
            title: Text("Delete \(editMode.isEditing ? "selected tags" : "this tag")?"),
            primaryButton: .destructive(Text("Delete")) {
                guard !selectedTags.isEmpty else { return }
                deleteTags(selectedTags)
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
