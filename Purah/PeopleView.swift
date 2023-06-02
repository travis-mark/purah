//  Purah - PeopleView.swift
//  Created by Travis Luckenbaugh on 5/31/23.

import SwiftUI
import Contacts

// TODO: Filters

struct ContactFieldName: View {
    let contact: CNContact
    let key: String
    
    var body: some View {
        if contact.isKeyAvailable(key) {
            if let string = contact.value(forKey: key) as? String {
                HStack {
                    Text(CNContact.localizedString(forKey: key))
                        .font(.headline)
                    Spacer()
                    Text(string)
                        .font(.subheadline)
                }
            // TODO: Handle CNLabeledValue
            } else {
                Text(CNContact.localizedString(forKey: key))
                    .font(.headline).foregroundColor(.red)
            }
        }
    }
}

struct ContactDetailView: View {
    @State var contact: CNContact
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ContactFieldName(contact: contact, key: CNContactJobTitleKey)
                ContactFieldName(contact: contact, key: CNContactOrganizationNameKey)
                ContactFieldName(contact: contact, key: CNContactEmailAddressesKey)
                ContactFieldName(contact: contact, key: CNContactPhoneNumbersKey)
                // TODO: Add more fields
                Spacer()
            }
        }
        .navigationTitle("\(contact.givenName) \(contact.familyName)")
        .padding()
        .onAppear {
            // TODO: Load full data
        }
    }
    
    func fetchContact() {
        let store = CNContactStore()
        let keysToFetch = [
            CNContactIdentifierKey,
            CNContactNamePrefixKey,
            CNContactGivenNameKey,
            CNContactMiddleNameKey,
            CNContactFamilyNameKey,
            CNContactPreviousFamilyNameKey,
            CNContactNameSuffixKey,
            CNContactNicknameKey,
            CNContactOrganizationNameKey,
            CNContactDepartmentNameKey,
            CNContactJobTitleKey,
            CNContactPhoneticGivenNameKey,
            CNContactPhoneticMiddleNameKey,
            CNContactPhoneticFamilyNameKey,
            CNContactPhoneticOrganizationNameKey,
            CNContactBirthdayKey,
            CNContactNonGregorianBirthdayKey,
            CNContactNoteKey,
            CNContactImageDataKey,
            CNContactThumbnailImageDataKey,
            CNContactImageDataAvailableKey,
            CNContactTypeKey,
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey,
            CNContactPostalAddressesKey,
            CNContactDatesKey,
            CNContactUrlAddressesKey,
            CNContactRelationsKey,
            CNContactSocialProfilesKey,
            CNContactInstantMessageAddressesKey,
        ] as [CNKeyDescriptor]
        
        DispatchQueue.global().async {
            store.requestAccess(for: .contacts) { granted, error in
                var result: CNContact?
                if granted {
                    let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
                    fetchRequest.predicate = CNContact.predicateForContacts(withIdentifiers: [contact.identifier])
                    
                    do {
                        try store.enumerateContacts(with: fetchRequest) { contact, _ in
                            result = contact
                        }
                    } catch {
                        print("Failed to fetch contact: \(error.localizedDescription)")
                    }
                }
                DispatchQueue.main.async {
                    if let result = result {
                        contact = result
                    }
                }
            }
        }
    }
}

struct PeopleView: View {
    @State private var accessGranted: Bool? = nil
    @State private var contacts: [CNContact] = []
    
    var body: some View {
        NavigationView {
            VStack {
                if accessGranted == true {
                    List(contacts, id: \.identifier) { contact in
                        NavigationLink(destination: ContactDetailView(contact: contact)) {
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
            }
            .navigationTitle("Address Book")
            .onAppear {
                fetchContacts()
            }
        }
    }
    
    func fetchContacts() {
        let store = CNContactStore()
        let keysToFetch = [CNContactIdentifierKey, CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        
        DispatchQueue.global().async {
            store.requestAccess(for: .contacts) { granted, error in
                var results = [CNContact]()
                accessGranted = granted
                if granted {
                    let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
                    
                    do {
                        try store.enumerateContacts(with: fetchRequest) { contact, _ in
                            results.append(contact)
                        }
                    } catch {
                        print("Failed to fetch contacts: \(error.localizedDescription)")
                    }
                }
                DispatchQueue.main.async {
                    accessGranted = granted
                    contacts = results
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
