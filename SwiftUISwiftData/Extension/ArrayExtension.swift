//
//  ArrayExtension.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/04.
//

import SwiftUI

extension Array {
    mutating func move(fromOffsets: [Int], toOffset: Int) {
        let source = IndexSet(fromOffsets)
        move(fromOffsets: source, toOffset: toOffset)
    }
}

extension Array where Element == Tag {
    var sortedByOrder: [Tag] {
        sorted { $0.order < $1.order }
    }
}
