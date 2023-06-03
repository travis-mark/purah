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
