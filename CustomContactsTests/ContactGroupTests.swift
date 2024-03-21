//
//  ContactGroupTests.swift
//  CustomContactsTests
//
//  Created by Robert Deans on 3/4/24.
//  Copyright © 2024 RBD. All rights reserved.
//

@testable import CustomContacts
@testable import CustomContactsModels
import Dependencies
import SwiftData
import XCTest

final class ContactGroupTests: XCTestCase {
	func testContactsArray() async {
		let testContacts = (1...10).map {
			Contact(id: "\($0)", firstName: "\($0)", lastName: "\($0)", displayName: "\($0)")
		}
		let testDictionary = Dictionary(testContacts.map { ($0.id, $0) }, uniquingKeysWith: { _, latest in latest })

		let contactsRepository = withDependencies {
			$0.contactsRepository.getContact = { contactID in
				testDictionary[contactID] // TODO: this will never get hit
			}
			$0.contactsService.fetchContacts = {
				testContacts
			}
		} operation: {
			ContactsRepository.testValue
		}
		_ = try? await contactsRepository.getAllContacts(true)

		let contactGroup = ContactGroup(
			id: "Test Group",
			name: "Test Group",
			contactIDs: ["1", "3", "7"],
			colorHex: ""
		)

		let expectedValue = [
			Contact(id: "1", firstName: "1", lastName: "1", displayName: "1"),
			Contact(id: "3", firstName: "3", lastName: "3", displayName: "3"),
			Contact(id: "7", firstName: "7", lastName: "7", displayName: "7"),
		]
		// Convert to Set because the Arrays are non-ordered in this state
		XCTAssertEqual(Set(contactGroup.contacts(from: contactsRepository)), Set(expectedValue))
	}
}
