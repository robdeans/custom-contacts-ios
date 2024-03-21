//
//  ContactListView.swift
//  CustomContacts
//
//  Created by Robert Deans on 8/14/23.
//  Copyright © 2023 RBD. All rights reserved.
//

import CustomContactsModels
import SwiftUI

struct ContactListView: View {
	@StateObject private var contactListNavigation = ContactListNavigation()
	@StateObject var viewModel: ViewModel

	var body: some View {
		NavigationStack(path: $contactListNavigation.path) {
			contentView
				.navigationDestination(for: contactListNavigation)
				.navigationTitle(Localizable.Root.Contacts.title)
				.toolbar {
					ToolbarItem(placement: .topBarTrailing) {
						Menu("🔃") {
							ForEach(Contact.SortOption.Parameter.allCases, id: \.rawValue) { parameter in
								Button(parameter.title) {
									viewModel.setSortOption(to: parameter)
								}
							}
							Divider()
							sortOrderButton(ascending: true)
							sortOrderButton(ascending: false)
						}
					}
				}
		}
		.environmentObject(contactListNavigation)
		.task {
			await viewModel.loadContacts(refresh: true)
		}
	}

	@ViewBuilder
	private var contentView: some View {
		if viewModel.isLoading {
			ProgressView()
		} else {
			VStack {
/*	Disable until functionality and placement can be better considered

				FilterView(
					filterQueries: viewModel.filterQueries,
					onAddQueryTapped: { viewModel.addQuery($0) },
					onRemoveQueryTapped: { viewModel.removeQuery($0) },
					onClearTapped: { viewModel.removeAllQueries() }
				)
*/
				List {
					ForEach(viewModel.contactsSections, id: \.0) { letter, contacts in
						Section(letter.capitalized) {
							ForEach(contacts) { contact in
								ContactCardView(contact: contact)
									.contentShape(Rectangle())
									.onTapGesture {
										contactListNavigation.path.append(.contactDetail(contact))
									}
							}
						}
					}
				}
				.listStyle(.plain)
				.searchable(text: $viewModel.searchText)
				.refreshable {
					await viewModel.loadContacts(refresh: true)
				}
			}
		}
	}

	private func sortOrderButton(ascending: Bool) -> some View {
		let title = ascending ? Localizable.Contacts.Sort.ascending
		: Localizable.Contacts.Sort.descending
		let checkmark = Contact.SortOption.current.ascending == ascending ? " ✓" : ""
		return Button(title + checkmark) {
			viewModel.setSortOption(ascending: ascending)
		}
	}
}

extension Contact.SortOption.Parameter {
	fileprivate var title: String {
		let checkmark = Contact.SortOption.current.parameter == self ? " ✓" : ""
		switch self {
		case .firstName:
			return Localizable.Contacts.Sort.firstName + checkmark
		case .lastName:
			return Localizable.Contacts.Sort.lastName + checkmark
		}
	}
}
