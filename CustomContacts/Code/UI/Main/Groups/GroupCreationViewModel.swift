//
//  GroupCreationViewModel.swift
//  CustomContacts
//
//  Created by Robert Deans on 3/27/24.
//  Copyright © 2024 RBD. All rights reserved.
//

import CustomContactsHelpers
import CustomContactsModels
import Dependencies
import Observation
import SwiftData
import SwiftUI

extension GroupCreationView {
	@Observable @MainActor
	final class ViewModel {
		var name = ""
		var color = Color.random
		@ObservationIgnored
		var selectedContactIDs: Set<Contact.ID> {
			Set(selectedContacts.map { $0.id })
		}
		private(set) var selectedContacts: [Contact] = []

		var showError = false

		func updateSelectedContacts(ids: Set<Contact.ID>) async {
			@Dependency(\.contactsRepository) var contactsRepository
			var contacts: [Contact] = []
			// TODO: should this alert if Contact ID is not found in dictionary? That should never happen...
			await withTaskGroup(of: Optional<Contact>.self) { group in
				for contactID in ids {
					group.addTask {
						return await contactsRepository.getContact(contactID)
					}
				}
				for await contact in group {
					if let contact {
						contacts.append(contact)
					}
				}
				selectedContacts = contacts
					.sorted(by: { $0.displayName < $1.displayName })
			}
		}
	}
}

extension GroupCreationView.ViewModel {
	/// Saves `ContactGroup` on main thread as this is a light data load
	/// and action is immediately related to user actions
	func createGroup(onCompletion: @escaping () -> Void) {
		Task(priority: .userInitiated) {
			PrintCurrentThread("createGroup")
			do {
				let container = try ModelContainer(for: ContactGroup.self)
				let handler = ContactGroupHandler(modelContainer: container)

				let groupID = try await handler.createGroup(
					name: name,
					contactIDs: selectedContactIDs,
					colorHex: color.toHex ?? ""
				)
				LogInfo("Group created: \(groupID)")
				onCompletion()
			} catch {
				LogError("Group creation failed: \(error.localizedDescription)")
				showError = true
			}
		}
	}
}
