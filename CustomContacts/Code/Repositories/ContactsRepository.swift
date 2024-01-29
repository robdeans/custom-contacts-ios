//
//  ContactsRepository.swift
//  CustomContacts
//
//  Created by Robert Deans on 8/15/23.
//  Copyright © 2023 RBD. All rights reserved.
//

import CustomContactsHelpers
import CustomContactsModels
import CustomContactsService
import Dependencies

struct ContactsRepository {
	/// Returns an array `[Contact]`
	///
	/// If `refresh: true` the array is fetched from ContactsService, otherwise the locally stored array is provided
	var getAllContacts: (_ refresh: Bool) async throws -> [Contact]

	/// Fetches a contact from a local dictionary; O(1) lookup time
	var getContact: (_ id: Contact.ID) -> Contact?

	/// Returns a local array of `[Contact]`; no conversions or computations
	var contacts: () -> [Contact]
}

extension DependencyValues {
	var contactsRepository: ContactsRepository {
		get { self[ContactsRepository.self] }
		set { self[ContactsRepository.self] = newValue }
	}
}

extension ContactsRepository: DependencyKey {
	static var liveValue: Self {
		@Dependency(\.contactsService) var contactsService

		// swiftlint:disable identifier_name
		var _contacts: [Contact] = []
		var contactDictionary: [Contact.ID: Contact] = [:]

		return Self(
			getAllContacts: { refresh in
				guard refresh else {
					return _contacts
				}
				guard try await contactsService.requestPermissions() else {
					// Permissions denied state; throw error?
					return []
				}
				_contacts = try await contactsService.fetchContacts()
				contactDictionary = Dictionary(
					_contacts.map { ($0.id, $0) },
					uniquingKeysWith: { _, last in last }
				)
				LogInfo("Repository returning \(_contacts.count) contact(s)")
				return _contacts
			},
			getContact: { contactDictionary[$0] },
			contacts: { _contacts }
		)
	}
	static let previewValue: ContactsRepository = .liveValue
	static let testValue: ContactsRepository = .liveValue

//	static var previewValue: Self {
//		Self(
//			getAllContacts: { _ in Contact.mockArray },
//			getContact: { _ in Contact.mock },
//			contacts: { Contact.mockArray }
//		)
//	}
//	static var testValue: Self {
//		@Dependency(\.contactsService) var contactsService
//
//		return Self(
//			getAllContacts: { _ in
//				try await contactsService.fetchContacts()
//			},
//			getContact: { _ in Contact.mock },
//			contacts: { Contact.mockArray }
//		)
//	}
}
