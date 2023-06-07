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

func string(fromStartDate startDate: Date, to endDate: Date) -> String {
    let calendar = Calendar.current
    if (startDate == endDate) {
        let dtfmt = DateFormatter()
        dtfmt.dateStyle = .short
        dtfmt.timeStyle = .short
        return dtfmt.string(from: startDate)
    } else {
        let startDay = calendar.dateComponents([.year, .month, .hour], from: startDate)
        let endDay = calendar.dateComponents([.year, .month, .hour], from: endDate)
        if (startDay != endDay) {
            let dfmt = DateFormatter()
            dfmt.dateStyle = .short
            dfmt.timeStyle = .none
            let tfmt = DateFormatter()
            tfmt.dateStyle = .none
            tfmt.timeStyle = .short
            return dfmt.string(from: startDate) + " " + tfmt.string(from: startDate) + " - " + tfmt.string(from: endDate)
        } else {
            let dfmt = DateFormatter()
            dfmt.dateStyle = .short
            dfmt.timeStyle = .none
            return dfmt.string(from: startDate) + " - " + dfmt.string(from: endDate)
        }
    }
    
    
}
