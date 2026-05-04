//
//  Item.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/05/04.
//

import Foundation
import SwiftData

@Model
final class Item {
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var order: Int

    init(title: String, content: String, createdAt: Date, updatedAt: Date, order: Int) {
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.order = order
    }
}
