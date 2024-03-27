//
//  ContactSelectorView.swift
//  CustomContacts
//
//  Created by Robert Deans on 8/14/23.
//  Copyright © 2023 RBD. All rights reserved.
//

import CustomContactsModels
import Dependencies
import Observation
import SwiftUI

struct ContactSelectorView: View {
	@Bindable private var viewModel = ViewModel()
	@Environment(\.dismiss) private var dismiss

	@State private var editMode = EditMode.active
	@State private var selectedContactIDs: Set<Contact.ID>

	private let onDoneTapped: (Set<Contact.ID>) -> Void

	init(
		selectedContactIDs: Set<Contact.ID>,
		onDoneTapped: @escaping (Set<Contact.ID>) -> Void
	) {
		self.onDoneTapped = onDoneTapped
		_selectedContactIDs = State(initialValue: selectedContactIDs)
	}

	var body: some View {
		NavigationStack {
			List(viewModel.contactsDisplayable, selection: $selectedContactIDs) {
				ContactCardView(contact: $0)
			}
			.searchable(text: $viewModel.searchText)
			.refreshable {
				await viewModel.loadContacts(refresh: true)
			}
			.environment(\.editMode, $editMode)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button(Localizable.Common.Actions.cancel) {
						dismiss()
					}
				}
				ToolbarItem(placement: .topBarTrailing) {
					Button(Localizable.Common.Actions.done) {
						onDoneTapped(selectedContactIDs)
						dismiss()
					}
				}
			}
		}
		.task {
			await viewModel.loadContacts()
		}
	}
}

extension ContactSelectorView: Identifiable {
	var id: String {
		@Dependency(\.uuid) var uuid
		return uuid().uuidString
	}
}

extension ContactSelectorView {
	// Could be `private` if not for Xcode warnings re: @Observable
	@Observable final class ViewModel {
		private var contacts: [Contact] = []
		var searchText = ""
		private(set) var error: Error?

		var contactsDisplayable: [Contact] {
			contacts.filter(searchText: searchText)
		}

		@MainActor func loadContacts(refresh: Bool = false) async {
			do {
				@Dependency(\.contactsRepository) var contactsRepository
				contacts = try await contactsRepository.fetchContacts(refresh: refresh)
			} catch {
				self.error = error
			}
		}
	}
}
