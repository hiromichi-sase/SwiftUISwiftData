//
//  ListButtonStyle.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/05/06.
//

import SwiftUI

protocol ListButtonStyle: ButtonStyle {
    var backgroundColor: Color { get }
    var pressedBackgroundColor: Color { get }

    func backgroundColor(isPressed: Bool) -> Color

    var editMode: EditMode { get }
}

extension ListButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .background(backgroundColor(isPressed: configuration.isPressed))
    }

    func backgroundColor(isPressed: Bool) -> Color {
        return editMode == .active ? .clear : (isPressed ? pressedBackgroundColor : backgroundColor)
    }
}

struct ListItemButtonStyle: ListButtonStyle {
    let editMode: EditMode

    var backgroundColor: Color = .clear
    var pressedBackgroundColor: Color = .init(uiColor: .systemGray5)
}
