//
//  FilterQuery.swift
//  CustomContacts
//
//  Created by Robert Deans on 8/31/23.
//  Copyright © 2023 RBD. All rights reserved.
//

import Combine
import CustomContactsModels
import Dependencies
import Observation

@Observable
final class FilterQuery: Identifiable {
	var id: String = {
		@Dependency(\.uuid) var uuid
		return uuid().uuidString
	}()

	var group: ContactGroup
	var filter = Filter.include
	var logic = LogicOperator.or

	init(isFirstQuery: Bool) {
		// First query should be `or` so base group is more inclusive of future clauses
		self.logic = isFirstQuery ? .or : .and

		group = ContactGroup.allContactsGroup
	}
}

extension FilterQuery {
	enum Filter: String, CaseIterable {
		case include
		case exclude
	}

	enum LogicOperator: String, CaseIterable {
		case and
		case or
	}
}

extension FilterQuery: Equatable {
	// TODO: revisit this when re-implementing filtering
	static func == (lhs: FilterQuery, rhs: FilterQuery) -> Bool {
		lhs.id == rhs.id
	}
}
