//  Purah - TodayView.swift
//  Created by Travis Luckenbaugh on 6/3/23.

import SwiftUI
import EventKit

// TODO: Event Detail View
// TODO: Reminder Detail View
// TODO: Date Picker
// TODO: Display Controls

struct TodayView: View {
    @State private var events: [EKEvent] = []
    @State private var reminders: [EKReminder] = []
    @State private var textDateStyle: Text.DateStyle = .time
    
    var calendarItems: [EKCalendarItem] {
        return events + reminders
    }
    
    var body: some View {
        List(calendarItems, id: \.calendarItemIdentifier) { item in
            if let event = item as? EKEvent {
                VStack(alignment: .leading) {
                    Text(event.title)
                        .font(.headline)
                    Text(event.startDate, style: textDateStyle)
                        .font(.subheadline)
                }
            } else if let reminder = item as? EKReminder {
                VStack(alignment: .leading) {
                    Text(reminder.title)
                        .font(.headline)
                    Text(reminder.dueDateComponents, style: textDateStyle)
                        .font(.subheadline)
                }
            } else {
                VStack {}
            }
        }
        .onAppear {
            loadEvents()
            loadReminders()
        }
    }
        
    func loadEvents() {
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { granted, error in
            if granted {
                let startDate = Date()
                let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
                let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
                let events = eventStore.events(matching: predicate)
                self.events = events
            } else {
                // handle error
            }
        }
    }
    
    func loadReminders() {
            let eventStore = EKEventStore()
            eventStore.requestAccess(to: .reminder) { granted, error in
                if granted {
                    let startDate = Date()
                    let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
                    let predicate = eventStore.predicateForReminders(in: nil)
                    eventStore.fetchReminders(matching: predicate) { reminders in
                        if let reminders = reminders {
                            self.reminders = reminders.filter { reminder in
                                guard let dueDate = reminder.dueDateComponents?.date else { return false }
                                return dueDate >= startDate && dueDate < endDate
                            }
                        }
                    }
                } else {
                    // handle error
                }
            }
        }
}
