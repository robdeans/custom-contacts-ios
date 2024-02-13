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

protocol ContactsRepository: Sendable {
	var contacts: [Contact] { get }
	func getAllContacts(_ refresh: Bool) async throws -> [Contact]
	func getContact(_ id: Contact.ID) -> Contact?
}

// TODO: remove `@unchecked`
final class ContactsRepositoryLive: @unchecked Sendable, ContactsRepository {
	private(set) var contacts: [Contact] = []
	private var contactDictionary: [Contact.ID: Contact] = [:]

	init() {}

	/// Returns an array `[Contact]`
	///
	/// If `refresh: true` the array is fetched from ContactsService, otherwise the locally stored array is provided
	func getAllContacts(_ refresh: Bool) async throws -> [Contact] {
		PrintCurrentThread("getAllContacts")
		guard refresh || contacts.isEmpty else {
			return contacts
		}
		@Dependency(\.contactsService) var contactsService
		guard try await contactsService.requestPermissions() else {
			// TODO: Permissions denied state; throw error?
			return []
		}
		let fetchContactsTask = Task(priority: .background) {
			PrintCurrentThread("fetchContactsTask")

			// TODO: minimize re-declaration of `contactsService`?
			@Dependency(\.contactsService) var contactsService
			contacts = try await contactsService.fetchContacts()
			contactDictionary = Dictionary(
				contacts.map { ($0.id, $0) },
				uniquingKeysWith: { _, last in last }
			)
			LogInfo("Repository returning \(self.contacts.count) contact(s)")
			return contacts
		}
		return try await fetchContactsTask.value
	}

	/// Fetches a contact from a local dictionary; O(1) lookup time
	func getContact(_ id: Contact.ID) -> Contact? {
		contactDictionary[id]
	}
}

extension DependencyValues {
	var contactsRepository: ContactsRepository {
		get { self[ContactsRepositoryKey.self] }
		set { self[ContactsRepositoryKey.self] = newValue }
	}
}

private enum ContactsRepositoryKey: DependencyKey {
	static var liveValue: ContactsRepository {
		ContactsRepositoryLive()
	}
}
