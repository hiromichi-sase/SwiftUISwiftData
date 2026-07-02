//
//  ArrayExtension.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/04.
//

import SwiftUI

extension Array where Element == Memo {
    mutating func move(from: [Int], to: Int) {
        let source = IndexSet(from)
        move(fromOffsets: source, toOffset: to)
    }
}
