//
//  ArrayExtension.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/04.
//

import SwiftUI

extension Array {
    mutating func move(from: [Int], to: Int) {
        let source = IndexSet(from)
        move(fromOffsets: source, toOffset: to)
    }
}

extension Array where Element == Tag {
    var sortedByOrder: [Tag] {
        sorted { $0.order < $1.order }
    }
}
