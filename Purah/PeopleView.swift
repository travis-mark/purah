//  Purah - PeopleView.swift
//  Created by Travis Luckenbaugh on 5/31/23.

import SwiftUI
import Contacts

// TODO: Better handling for blanks / gaps
// TODO: Filters

struct ContactImageView: View {
    let contact: CNContact
    
    var body: some View {
        if contact.isKeyAvailable(CNContactImageDataAvailableKey) && contact.imageDataAvailable, let data = contact.imageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
        } else if contact.isKeyAvailable(CNContactTypeKey) {
            Image(systemName: contact.contactType.rawValue == 0 ? "person" : "building")
        } else {
            Image(systemName: "questionmark.circle")
        }
    }
}

struct ContactDetailView: View {
    @State var contact: CNContact
    
    var body: some View {
        List {
            if contact.isKeyAvailable(CNContactOrganizationNameKey) || contact.isKeyAvailable(CNContactDepartmentNameKey) || contact.isKeyAvailable(CNContactJobTitleKey) {
                Section("") {
                    if contact.isKeyAvailable(CNContactOrganizationNameKey), contact.organizationName != "" {
                        HStack {
                            Text(CNContact.localizedString(forKey: CNContactOrganizationNameKey))
                            Spacer()
                            Text(contact.organizationName)
                        }
                    }
                    if contact.isKeyAvailable(CNContactDepartmentNameKey), contact.departmentName != "" {
                        HStack {
                            Text(CNContact.localizedString(forKey: CNContactDepartmentNameKey))
                            Spacer()
                            Text(contact.departmentName)
                        }
                    }
                    if contact.isKeyAvailable(CNContactJobTitleKey), contact.jobTitle != "" {
                        HStack {
                            Text(CNContact.localizedString(forKey: CNContactJobTitleKey))
                            Spacer()
                            Text(contact.jobTitle)
                        }
                    }
                }
            }
            // Birthday
            if contact.isKeyAvailable(CNContactBirthdayKey), let birthday = contact.birthday {
                HStack(alignment: .top) {
                    Text(CNContact.localizedString(forKey: CNContactBirthdayKey))
                        .font(.headline)
                    Spacer()
                    Text(birthday, style: .date)
                }
            }
            // Phone Number
            if contact.isKeyAvailable(CNContactPhoneNumbersKey) && contact.phoneNumbers.count > 0 {
                VStack {
                    HStack {
                        Text(CNContact.localizedString(forKey: CNContactPhoneNumbersKey))
                            .font(.headline)
                        Spacer()
                    }
                    ForEach(contact.phoneNumbers, id:\.identifier) { record in
                        if let label = record.label {
                            let localized = CNLabeledValue<NSString>.localizedString(forLabel: label)
                            HStack {
                                Text(localized).font(.subheadline)
                                Spacer()
                                Text(record.value.stringValue)
                            }
                        }
                    }
                }
            }
            // E-mail Addresses
            if contact.isKeyAvailable(CNContactEmailAddressesKey) && contact.emailAddresses.count > 0 {
                VStack {
                    HStack {
                        Text(CNContact.localizedString(forKey: CNContactEmailAddressesKey))
                            .font(.headline)
                        Spacer()
                    }
                    ForEach(contact.phoneNumbers, id:\.identifier) { record in
                        if let label = record.label {
                            let localized = CNLabeledValue<NSString>.localizedString(forLabel: label)
                            HStack {
                                Text(localized).font(.subheadline)
                                Spacer()
                                Text(record.value.stringValue)
                            }
                        }
                    }
                }
            }
            if contact.isKeyAvailable(CNContactPostalAddressesKey) && contact.postalAddresses.count > 0 {
                VStack {
                    HStack {
                        Text(CNContact.localizedString(forKey: CNContactPostalAddressesKey))
                            .font(.headline)
                        Spacer()
                    }
                    ForEach(contact.postalAddresses, id:\.identifier) { record in
                        if let label = record.label {
                            let localized = CNLabeledValue<NSString>.localizedString(forLabel: label)
                            HStack {
                                Text(localized).font(.subheadline)
                                Spacer()
                                Text(CNPostalAddressFormatter.string(from: record.value, style: .mailingAddress))
                            }
                        }
                    }
                }
            }
            if contact.isKeyAvailable(CNContactDatesKey) && contact.dates.count > 0 {
                VStack {
                    HStack {
                        Text(CNContact.localizedString(forKey: CNContactDatesKey))
                            .font(.headline)
                        Spacer()
                    }
                    ForEach(contact.dates, id:\.identifier) { record in
                        if let label = record.label {
                            let localized = CNLabeledValue<NSString>.localizedString(forLabel: label)
                            HStack {
                                Text(localized).font(.subheadline)
                                Spacer()
                                Text(record.value as DateComponents, style: .date)
                            }
                        }
                    }
                }
            }
            if contact.isKeyAvailable(CNContactRelationsKey) && contact.contactRelations.count > 0 {
                VStack {
                    HStack {
                        Text(CNContact.localizedString(forKey: CNContactRelationsKey))
                            .font(.headline)
                        Spacer()
                    }
                    ForEach(contact.contactRelations, id:\.identifier) { record in
                        if let label = record.label {
                            let localized = CNLabeledValue<NSString>.localizedString(forLabel: label)
                            HStack {
                                Text(localized).font(.subheadline)
                                Spacer()
                                Text(record.value.name)
                            }
                        }
                    }
                }
            }
            if contact.isKeyAvailable(CNContactUrlAddressesKey) && contact.urlAddresses.count > 0 {
                VStack {
                    HStack {
                        Text(CNContact.localizedString(forKey: CNContactUrlAddressesKey))
                            .font(.headline)
                        Spacer()
                    }
                    ForEach(contact.urlAddresses, id:\.identifier) { record in
                        if let label = record.label {
                            let localized = CNLabeledValue<NSString>.localizedString(forLabel: label)
                            HStack {
                                Text(localized).font(.subheadline)
                                Spacer()
                                Text(record.value as String)
                            }
                        }
                    }
                }
            }
            // TODO: ContactFieldName(contact: contact, key: CNContactSocialProfilesKey)
            // TODO: ContactFieldName(contact: contact, key: CNContactInstantMessageAddressesKey)
        }
        .navigationTitle("\(contact.givenName) \(contact.familyName)")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: ContactImageView(contact: contact))
        .onAppear {
            fetchContact()
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
    //            com.apple.developer.contacts.notes is bullshit
    //            https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_contacts_notes
    //            CNContactNoteKey,
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
        ]
        
        DispatchQueue.global().async {
            store.requestAccess(for: .contacts) { granted, accessError in
                var result: CNContact?
                if granted {
                    let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch as [CNKeyDescriptor])
                    fetchRequest.predicate = CNContact.predicateForContacts(withIdentifiers: [contact.identifier])
                    
                    do {
                        try store.enumerateContacts(with: fetchRequest) { contact, _ in
                            result = contact
                        }
                    } catch {
                        let fetchError = error
                        print("Failed to fetch contact: \(fetchError.localizedDescription)")
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
