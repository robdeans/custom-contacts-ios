//
//  FilterQueryTests.swift
//  CustomContactsTests
//
//  Created by Robert Deans on 3/4/24.
//  Copyright © 2024 RBD. All rights reserved.
//

@testable import CustomContacts
import Dependencies
import XCTest

final class FilterQueryTests: XCTestCase {
	func testFilterQuery() {
		let filterQueryID = UUID(uuidString: "37FE34F8-1910-4547-A072-28248C8F9057")!
		let filterQuery = withDependencies {
			$0.uuid = .constant(filterQueryID)
		} operation: {
			FilterQuery(isFirstQuery: true)
		}

		XCTAssertEqual(filterQuery.id, filterQueryID.uuidString)
	}
}
