//
//  ContactListViewModel.swift
//  CustomContacts
//
//  Created by Robert Deans on 9/1/23.
//  Copyright © 2023 RBD. All rights reserved.
//

import Combine
import CustomContactsModels
import Dependencies
import Observation

extension ContactListView {
	@Observable final class ViewModel {
		@ObservationIgnored @Dependency(\.contactsRepository) private var contactsRepository
		private(set) var contacts: [Contact] = []
		private(set) var isLoading = false
		private(set) var error: Error?

		var searchText = ""
		private(set) var filterQueries: [FilterQuery] = []

		@MainActor func loadContacts(refresh: Bool = false) async {
			defer {
				isLoading = false
			}
			error = nil
			isLoading = true

			do {
				contacts = try await contactsRepository.getAllContacts(refresh)
			} catch {
				self.error = error
			}
		}
	}
}

extension ContactListView.ViewModel {
	func contactsSections() -> [(String, [Contact])] {
		var valueDictionary: [String: [Contact]] = [:]
		contactsDisplayable().forEach { contact in
			let letter = {
				switch Contact.SortOption.current.parameter {
				case .firstName:
					contact.firstName.first.map { String($0).uppercased() } ?? "-"
				case .lastName:
					contact.lastName.first.map { String($0).uppercased() } ?? "-"
				}
			}()
			var contacts = valueDictionary[letter] ?? []
			contacts.append(contact)
			valueDictionary[letter] = contacts
		}
		return valueDictionary
			.map { ($0.key, $0.value) }
			.sorted()
	}

	// Given the switch case and usage of Set methods, this could be more efficient.
	// TODO: re-test with larger contacts data set and
	// TODO: add test coverage
	private func contactsDisplayable() -> [Contact] {
		/// Forces `contactsDisplayable` to update when `\.contacts` changes (?)
		access(keyPath: \.contacts)

		var filteredContactIDs = Set<Contact.ID>()
		if !filterQueries.isEmpty {
			filterQueries.forEach {
				switch $0.logic {
				case .and:
					switch $0.filter {
					case .include:
						filteredContactIDs.formIntersection($0.group.contactIDs)
					case .exclude:
						var allContactIDsExcludingGroup = contactsRepository.contactIDs()
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
						var allContactIDsExcludingGroup = contactsRepository.contactIDs()
						$0.group.contactIDs.forEach {
							allContactIDsExcludingGroup.remove($0)
						}
						filteredContactIDs.formUnion(allContactIDsExcludingGroup)
					}
				}
			}
		} else {
			filteredContactIDs = contactsRepository.contactIDs()
		}

		return filteredContactIDs
			.compactMap(contactsRepository.getContact)
			.filter(searchText: searchText)
	}
}

extension ContactListView.ViewModel {
	func setSortOption(to parameter: Contact.SortOption.Parameter? = nil, ascending: Bool? = nil) {
		let updatedSortOption = Contact.SortOption(
			parameter: parameter ?? Contact.SortOption.current.parameter,
			ascending: ascending ?? Contact.SortOption.current.ascending
		)
		@Dependency(\.contactsProvider) var contactsProvider
		contacts = contactsProvider.sortContacts(updatedSortOption)
	}

	func addQuery(_ query: FilterQuery) {
		filterQueries.append(query)
	}

	func removeQuery(_ query: FilterQuery) {
		if let index = filterQueries.firstIndex(where: { $0.id == query.id }) {
			filterQueries.remove(at: index)
		}
	}

	func removeAllQueries() {
		filterQueries.removeAll()
	}
}
