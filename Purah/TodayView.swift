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
                HStack {
                    Image(systemName: "calendar")
                    VStack(alignment: .leading) {
                        Text(event.title)
                            .font(.headline)
                        Text(event.startDate, style: textDateStyle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            } else if let reminder = item as? EKReminder {
                HStack {
                    if reminder.completionDate != nil {
                        Image(systemName: "checkmark.circle")
                    } else {
                        Image(systemName: "circle")
                    }
                    VStack(alignment: .leading) {
                        Text(reminder.title)
                            .font(.headline)
                        Text(reminder.dueDateComponents, style: textDateStyle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                HStack {}
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
                let (start, end) = daySpan(of: Date())
                let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: nil)
                let events = eventStore.events(matching: predicate)
                self.events = events
            } else {
                // TODO: Events handle error
            }
        }
    }
    
    func loadReminders() {
            let eventStore = EKEventStore()
            eventStore.requestAccess(to: .reminder) { granted, error in
                if granted {
                    let (start, end) = daySpan(of: Date())
                    let predicate = eventStore.predicateForReminders(in: nil)
                    eventStore.fetchReminders(matching: predicate) { reminders in
                        if let reminders = reminders {
                            self.reminders = reminders.filter { reminder in
                                guard let dueDate = reminder.dueDateComponents?.date else { return false }
                                return dueDate >= start && dueDate < end
                            }
                        }
                    }
                } else {
                    // TODO: Reminder handle error
                }
            }
        }
}
