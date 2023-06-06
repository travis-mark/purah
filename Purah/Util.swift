//  Purah - Util.swift
//  Created by Travis Luckenbaugh on 6/3/23.

import Foundation
import SwiftUI

extension Text {
    init(_ dc: DateComponents?, style: DateStyle) {
        if let dc = dc, let date = Calendar.current.date(from: dc) {
            self = Text(date, style: style)
        } else {
            self = Text("NULL")
        }
    }
}

func daySpan(of date: Date) -> (Date, Date) {
    let calendar = Calendar.current
    let midnight = calendar.startOfDay(for: date)
    return (
        calendar.date(bySettingHour: 0, minute: 0, second: 0, of: midnight) ?? date,
        calendar.date(bySettingHour: 23, minute: 59, second: 59, of: midnight) ?? date
    )
}
