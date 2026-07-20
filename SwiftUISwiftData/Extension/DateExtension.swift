//
//  DateExtension.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/20.
//

import SwiftUI

extension Date {
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        let weekday = formatter.string(from: self)
        let date = formatted(date: .numeric, time: .omitted)
        let time = formatted(date: .omitted, time: .standard)
        return "\(weekday) \(date) \(time)"
    }
}
