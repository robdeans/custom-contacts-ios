//
//  ContactListViewModelTest.swift
//  CustomContactsTests
//
//  Created by Robert Deans on 9/11/23.
//  Copyright © 2023 RBD. All rights reserved.
//

import CustomContactsModels
import Dependencies
import XCTest

final class ContactListViewModelTest: XCTestCase {
	func testLoadContacts() async {
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

		XCTAssertEqual(viewModel.contacts, [])
		XCTAssertTrue(viewModel.error == nil)
		XCTAssertFalse(viewModel.isLoading)
		
		await viewModel.loadContacts(refresh: true)
		
		XCTAssertFalse(viewModel.isLoading)
		XCTAssertTrue(viewModel.error == nil)
		XCTAssertEqual(viewModel.contacts, Contact.mockArray)
		XCTAssertTrue(didTestLoad)
	}

	func testLoadContactsError() async {
		let viewModel = withDependencies {
			$0.contactsRepository.getAllContacts = { _ in
				struct SomeError: Error {}
				throw SomeError()
			}
		} operation: {
			ContactListView.ViewModel()
		}
		await viewModel.loadContacts(refresh: true)
		XCTAssert(viewModel.error != nil)

	}
}
