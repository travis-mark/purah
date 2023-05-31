//  Purah - PeopleView.swift
//  Created by Travis Luckenbaugh on 5/31/23.

import SwiftUI
import Contacts

// TODO: PeopleDetailView
// TODO: Filters

struct PeopleView: View {
    @State private var accessGranted: Bool? = nil
    @State private var contacts: [CNContact] = []
    
    var body: some View {
        VStack {
            if accessGranted == true {
                List(contacts, id: \.identifier) { contact in
                    VStack(alignment: .leading) {
                        Text("\(contact.givenName) \(contact.familyName)")
                            .font(.headline)
                        if let firstPhoneNumber = contact.phoneNumbers.first {
                            Text(firstPhoneNumber.value.stringValue)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } else {
                VStack {
                    Text("\(bundleName()) does not have access to contacts.")
                    Button("Open Settings") {
                        if let bundleIdentifier = Bundle.main.bundleIdentifier,
                           let appSettingsURL = URL(string: UIApplication.openSettingsURLString + bundleIdentifier) {
                            UIApplication.shared.open(appSettingsURL, options: [:], completionHandler: nil)
                        }
                    }
                }
            }
        }.onAppear {
            fetchContacts()
        }
        .navigationTitle("Address Book")
    }
    
    func fetchContacts() {
        let store = CNContactStore()
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        
        store.requestAccess(for: .contacts) { granted, error in
            accessGranted = granted
            if granted {
                let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
                
                do {
                    try store.enumerateContacts(with: fetchRequest) { contact, _ in
                        contacts.append(contact)
                    }
                } catch {
                    print("Failed to fetch contacts: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct PeopleView_Previews: PreviewProvider {
    static var previews: some View {
        PeopleView()
    }
}
