//
//  ContactListViewModelTest.swift
//  CustomContactsTests
//
//  Created by Robert Deans on 9/11/23.
//  Copyright © 2023 RBD. All rights reserved.
//

@testable import CustomContacts
@testable import CustomContactsModels
import Dependencies
import XCTest

final class ContactListViewModelTest: XCTestCase {
	func testLoadContacts() async {
		let testContacts = [
			Contact(id: "Test 1", firstName: "Test 1", lastName: "Test 1", displayName: "testLoadContacts 1"),
			Contact(id: "Test 2", firstName: "Test 2", lastName: "Test 2", displayName: "testLoadContacts 2"),
			Contact(id: "Test 3", firstName: "Test 3", lastName: "Test 3", displayName: "testLoadContacts 3"),
		]

		let viewModel = withDependencies {
			$0.contactsService.fetchContacts = {
				testContacts
			}
		} operation: {
			ContactListView.ViewModel()
		}

		XCTAssertTrue(viewModel.contacts.isEmpty)
		XCTAssertTrue(viewModel.error == nil)
		XCTAssertFalse(viewModel.isLoading)
		
		await viewModel.loadContacts(refresh: true)
		
		XCTAssertFalse(viewModel.isLoading)
		XCTAssertTrue(viewModel.error == nil)
		XCTAssertEqual(viewModel.contacts, testContacts)
	}

	func testLoadContactsError() async {
		let contactsRepository = withDependencies {
			$0.contactsService.fetchContacts = {
				struct SomeError: Error {}
				throw SomeError()
			}
		} operation: {
			ContactsRepository.testValue
		}
		let viewModel = withDependencies {
			$0.contactsRepository = contactsRepository
		} operation: {
			ContactListView.ViewModel()
		}
		XCTAssert(contactsRepository.contacts().isEmpty)
		await viewModel.loadContacts(refresh: true)
		XCTAssert(viewModel.error != nil)
	}

	func testIsLoadingIndicator() async {
		var testIsLoading: (() -> Void)?
		let viewModel = withDependencies {
			$0.contactsRepository.getAllContacts = { _ in
				testIsLoading?()
				return Contact.mockArray
			}
		} operation: {
			ContactListView.ViewModel()
		}
		var didTestLoad = false
		testIsLoading = { [weak viewModel] in
			didTestLoad = true
			XCTAssertTrue(viewModel!.isLoading)
		}

		XCTAssertFalse(viewModel.isLoading)
		await viewModel.loadContacts(refresh: true)
		XCTAssertFalse(viewModel.isLoading)

		XCTAssertTrue(didTestLoad)
	}
}
