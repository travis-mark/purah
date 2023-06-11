//  Purah - TodayView.swift
//  Created by Travis Luckenbaugh on 6/3/23.

import SwiftUI
import EventKit

// TODO: Event Detail View
// TODO: Reminder Detail View
// TODO: Date Picker
// TODO: Display Controls

struct ReminderViewModel {
    let calendarItemIdentifier: String
    let completionDate: Date?
    let dueDateComponents: DateComponents?
    var isCompleted: Bool
    let title: String
    let sourceObject: EKReminder?
    
    init(_ reminder: EKReminder) {
        calendarItemIdentifier = reminder.calendarItemIdentifier
        completionDate = reminder.completionDate
        dueDateComponents = reminder.dueDateComponents
        isCompleted = reminder.isCompleted
        title = reminder.title
        sourceObject = reminder
    }
}

struct TodayView: View {
    private let eventStore = EKEventStore()
    @State private var events: [EKEvent] = []
    @State private var reminders: [ReminderViewModel] = []
    @State private var textDateStyle: Text.DateStyle = .time
    
    
    var body: some View {
        List {
            ForEach(events, id: \.calendarItemIdentifier) { event in
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
            }
            ForEach(Array(reminders.enumerated()), id: \.1.calendarItemIdentifier) { index, reminder in
                HStack {
                    Image(systemName: reminder.isCompleted ? "checkmark.circle" : "circle")
                        .onTapGesture {
                            guard let object = reminder.sourceObject else { return }
                            object.completionDate = reminder.completionDate != nil ? nil : Date()
                            object.isCompleted = !reminder.isCompleted
                            reminders[index] = ReminderViewModel(object)
                            do {
                                try eventStore.save(object, commit: true)
                            } catch {
                                showError(error)
                            }
                        }
                    VStack(alignment: .leading) {
                        Text(reminder.title)
                            .font(.headline)
                        Text(reminder.dueDateComponents, style: textDateStyle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .onAppear {
            loadEvents()
            loadReminders()
        }
    }
        
    func loadEvents() {
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
        eventStore.requestAccess(to: .reminder) { granted, error in
            if granted {
                let (start, end) = daySpan(of: Date())
                let predicate = eventStore.predicateForReminders(in: nil)
                eventStore.fetchReminders(matching: predicate) { reminders in
                    if let reminders = reminders {
                        self.reminders = reminders.filter { reminder in
                            guard let dueDate = reminder.dueDateComponents?.date else { return false }
                            return dueDate >= start && dueDate < end
                        }.map({ ReminderViewModel($0) })
                    }
                }
            } else {
                // TODO: Reminder handle error
            }
        }
    }
}
