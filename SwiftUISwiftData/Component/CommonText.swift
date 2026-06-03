//
//  CommonText.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/05/24.
//

import SwiftUI

/// TitleText is a helper function that creates a Text view for a title. If the title is empty, it displays a default message and uses a secondary foreground style. Otherwise, it displays the provided title with the primary foreground style.
/// - Parameter title: The title string to be displayed. If this string is empty, a default message will be shown instead.
/// - Returns: A Text view that displays the title or a default message, styled appropriately based on whether the title is empty or not.
func TitleText(_ title: String) -> Text {
    Text(title.isEmpty ? CommonString.emptyTitle.rawValue : title)
        .foregroundStyle(title.isEmpty ? .secondary : .primary)
}
