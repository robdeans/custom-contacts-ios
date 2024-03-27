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
import Foundation

extension ContactListView {
	final class ViewModel: ObservableObject {
		@Published private var contacts: [Contact] = []
		@Published private(set) var contactsSections: [(String, [Contact])] = []

		@Published var searchText = ""
		@Published private(set) var filterQueries: [FilterQuery] = []

		@Published private(set) var isLoading = false
		@Published private(set) var error: Error?

		private var cancellables = Set<AnyCancellable>()

		init() {
			Publishers.CombineLatest3(
				$contacts.removeDuplicates(),
				$searchText
					.debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
					.removeDuplicates(),
				$filterQueries.removeDuplicates()
			)
			.map(Self.contactsSection)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] in
				self?.contactsSections = $0
			}
			.store(in: &cancellables)
		}

		@MainActor func loadContacts(refresh: Bool = false) async {
			defer {
				isLoading = false
			}
			error = nil
			isLoading = true

			do {
				@Dependency(\.contactsRepository) var contactsRepository
				contacts = try await contactsRepository.fetchContacts(refresh: refresh)
			} catch {
				self.error = error
			}
		}
	}
}

extension ContactListView.ViewModel {
	private static func contactsSection(
		contacts: [Contact],
		searchText: String,
		filterQueries: [FilterQuery]
	) -> [(String, [Contact])] {
		@Dependency(\.contactsProvider) var contactsProvider
		let contactsDisplayable = contactsProvider.filterContacts(contacts, filterQueries)
			.filter(searchText: searchText)

		var valueDictionary: [String: [Contact]] = [:]

		contactsDisplayable.forEach { contact in
			let letter = {
				switch Contact.SortOption.current.parameter {
				case .firstName:
					contact.firstName.first.map { String($0).uppercased() } ?? "-"
				case .lastName:
					contact.lastName.first.map { String($0).uppercased() } ?? "-"
				}
			}()
			valueDictionary[letter] = (valueDictionary[letter] ?? []) + [contact]
		}
		return valueDictionary
			.map { ($0.key, $0.value) }
			.sorted()
	}
}

extension ContactListView.ViewModel {
	func setSortOption(to parameter: Contact.SortOption.Parameter? = nil, ascending: Bool? = nil) {
		let updatedSortOption = Contact.SortOption(
			parameter: parameter ?? Contact.SortOption.current.parameter,
			ascending: ascending ?? Contact.SortOption.current.ascending
		)
		@Dependency(\.contactsProvider) var contactsProvider
		contacts = contactsProvider.sortContacts(contacts, updatedSortOption)
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
