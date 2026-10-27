//
//  DateExtension.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/20.
//

import SwiftUI

extension Date {
    private static let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()

    var dateString: String {
        let weekday = Self.weekdayFormatter.string(from: self)
        let date = formatted(date: .numeric, time: .omitted)
        let time = formatted(date: .omitted, time: .shortened)
        return "\(weekday) \(date) \(time)"
    }
}
