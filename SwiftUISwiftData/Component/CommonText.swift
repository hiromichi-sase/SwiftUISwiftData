//
//  CommonText.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/05/24.
//

import SwiftUI

func TitleText(_ title: String) -> Text {
    Text(title.isEmpty ? CommonString.emptyTitle.rawValue : title)
        .foregroundStyle(title.isEmpty ? .secondary : .primary)
}
