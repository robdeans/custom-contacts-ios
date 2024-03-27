//
//  ContactsProvider.swift
//  CustomContacts
//
//  Created by Robert Deans on 1/26/24.
//  Copyright © 2024 RBD. All rights reserved.
//

import CustomContactsModels
import Dependencies

struct ContactsProvider: Sendable {
	var sortContacts: @Sendable ([Contact], Contact.SortOption) -> [Contact]
	var filterContacts: @Sendable ([Contact], [FilterQuery]) -> [Contact]
}

extension DependencyValues {
	var contactsProvider: ContactsProvider {
		get { self[ContactsProvider.self] }
		set { self[ContactsProvider.self] = newValue }
	}
}

extension ContactsProvider: DependencyKey {
	static var liveValue: ContactsProvider {
		Self(
			sortContacts: { contacts, sortOption in
				@Dependency(\.userSettings) var userSettings
				userSettings.setSortOption(sortOption)
				return contacts.sorted(by: sortOption)
			},
			filterContacts: { contacts, filterQueries in
				// Given the switch case and usage of Set methods, this could be more efficient.
				// TODO: re-test with larger contacts data set and

				let contactIDs = Set(contacts.map { $0.id })
				var filteredContactIDs = Set<Contact.ID>()
				if !filterQueries.isEmpty {
					filterQueries.forEach {
						switch $0.logic {
						case .and:
							switch $0.filter {
							case .include:
								filteredContactIDs.formIntersection($0.group.contactIDs)
							case .exclude:
								var allContactIDsExcludingGroup = contactIDs
								$0.group.contactIDs.forEach {
									filteredContactIDs.remove($0)
									allContactIDsExcludingGroup.remove($0)
								}
								filteredContactIDs.formUnion(allContactIDsExcludingGroup)
							}
						case .or:
							switch $0.filter {
							case .include:
								filteredContactIDs.formUnion($0.group.contactIDs)
							case .exclude:
								var allContactIDsExcludingGroup = contactIDs
								$0.group.contactIDs.forEach {
									allContactIDsExcludingGroup.remove($0)
								}
								filteredContactIDs.formUnion(allContactIDsExcludingGroup)
							}
						}
					}
				} else {
					filteredContactIDs = contactIDs
				}

				return contacts
				// TODO: fix stuff here too
//				@Dependency(\.contactsRepository) var contactsRepository
//				return filteredContactIDs
//					.compactMap(contactsRepository.getContact)
			}
		)
	}
}
