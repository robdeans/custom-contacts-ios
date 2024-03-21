//
//  FilterRowView.swift
//  CustomContacts
//
//  Created by Robert Deans on 8/31/23.
//  Copyright © 2023 RBD. All rights reserved.
//

import CustomContactsModels
import Dependencies
import SwiftData
import SwiftUI

struct FilterRowView: View {
	@Bindable var filterQuery: FilterQuery
	let isFirstRow: Bool

	@Environment(\.modelContext) private var modelContext
	@Query(sort: [SortDescriptor(\ContactGroup.name)])
	private var groups: [ContactGroup]

	private var borderColor: Color {
		if filterQuery.group == ContactGroup.allContactsGroup {
			return .clear
		}
		return filterQuery.group.color
	}

	var body: some View {
		Group {
			if isFirstRow {
				firstRowContentView
			} else {
				rowContentView
			}
		}
		.border(borderColor)
	}
}

// MARK: - View Components
extension FilterRowView {
	private var firstRowContentView: some View {
		HStack {
			pickerView(for: FilterQuery.Filter.allCases, selected: $filterQuery.filter)
			Text(Localizable.Filter.Row.withinTheGroup)
			groupsPickerView
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}

	private var rowContentView: some View {
		VStack {
			HStack {
				pickerView(for: FilterQuery.LogicOperator.allCases, selected: $filterQuery.logic)
				Text(Localizable.Filter.Row.contactsWhoAre)
				pickerView(for: FilterQuery.Filter.allCases, selected: $filterQuery.filter)
			}
			.frame(maxWidth: .infinity, alignment: .leading)

			HStack {
				Text(Localizable.Filter.Row.withinTheGroup)
				groupsPickerView
			}
			.frame(maxWidth: .infinity, alignment: .leading)
		}
	}

	private var groupsPickerView: some View {
		Picker("", selection: $filterQuery.group) {
			Text(ContactGroup.allContactsGroup.name)
				.tag(ContactGroup.allContactsGroup)
			ForEach(groups) {
				Text($0.name)
					.tag($0)
			}
		}
	}

	private func pickerView<T: PickerProtocol>(for collection: [T], selected: Binding<T>) -> some View {
		Picker("", selection: selected) {
			ForEach(collection) {
				Text($0.title)
					.tag($0)
			}
		}
	}
}

private protocol PickerProtocol: Identifiable, Hashable {
	var title: String { get }
}

extension FilterQuery.LogicOperator: PickerProtocol {
	var id: String {
		rawValue
	}

	fileprivate var title: String {
		rawValue.capitalized
	}
}

extension FilterQuery.Filter: PickerProtocol {
	var id: String {
		rawValue
	}

	fileprivate var title: String {
		switch self {
		case .include:
			return Localizable.Filter.Row.found
		case .exclude:
			return Localizable.Filter.Row.notFound
		}
	}
}
