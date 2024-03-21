//
//  ContactsService+Live.swift
//  CustomContacts
//
//  Created by Robert Deans on 9/11/23.
//  Copyright © 2023 RBD. All rights reserved.
//

import Contacts
import CustomContactsHelpers
import CustomContactsModels

extension ContactsService {
	public static var liveValue: Self {
		let store = CNContactStore()
		let keysToFetch: [Any] = [
			CNContactIdentifierKey,
			CNContactTypeKey,
			CNContactGivenNameKey,
			CNContactFamilyNameKey,
			CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
			CNContactOrganizationNameKey,
			CNContactEmailAddressesKey,
			CNContactPostalAddressesKey,
			CNContactPhoneNumbersKey,
		]

		return Self(
			fetchContacts: {
				let request = CNContactFetchRequest(keysToFetch: keysToFetch.compactMap { $0 as? CNKeyDescriptor })
				return try await withCheckedThrowingContinuation { continuation in
					do {
						var contacts: [Contact] = []
						try store.enumerateContacts(with: request) { cnContact, _ in
							contacts.append(Contact(cnContact))
						}
						LogInfo("Service returning \(contacts.count) contact(s)")
						continuation.resume(returning: contacts)
					} catch {
						continuation.resume(throwing: error)
					}
				}
			},
			requestPermissions: {
				let contactsAuthorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
				switch contactsAuthorizationStatus {
				case .authorized:
					return true
				case .notDetermined:
					do {
						return try await store.requestAccess(for: .contacts)
					} catch {
						throw error
					}
				case .restricted, .denied:
					return false
				@unknown default:
					LogWarning("Unknown Contact permissions case: \(contactsAuthorizationStatus)")
					return false
				}
			}
		)
	}
}
