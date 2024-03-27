//
//  ContactGroup+Extensions.swift
//  CustomContacts
//
//  Created by Robert Deans on 8/15/23.
//  Copyright © 2023 RBD. All rights reserved.
//

import CustomContactsHelpers
import CustomContactsModels
import Dependencies
import SwiftUI

extension ContactGroup {
	var color: Color {
		Color(hex: colorHex)
	}

	static var empty: ContactGroup {
		@Dependency(\.uuid) var uuid
		return ContactGroup(
			id: uuid().uuidString,
			name: "",
			contactIDs: [],
			colorHex: Color.random.toHex ?? ""
		)
	}

	static var allContactsGroup: ContactGroup {
		@Dependency(\.contactsRepository) var contactsRepository
		return ContactGroup(
			id: "",
			name: "All Contacts",
			contactIDs: [], //Set(contactsRepository.getContacts().map { $0.id }),
			colorHex: ""
		)
	}

	func contacts() -> [Contact] {
		[]
//		@Dependency(\.contactsRepository) var contactsRepository
//		return self.contactIDs
//			.compactMap { await contactsRepository.getContact($0) }
	}
}

// TODO: fix stuff here... getContacts()
