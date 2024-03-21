//
//  GroupCardView.swift
//  CustomContacts
//
//  Created by Robert Deans on 8/15/23.
//  Copyright © 2023 RBD. All rights reserved.
//

import CustomContactsModels
import Dependencies
import SwiftUI

struct GroupCardView: View {
	@EnvironmentObject private var groupNavigation: GroupListNavigation
	@State private var isExpanded = false

	private let viewModel: ViewModel
	private let onGroupTapped: () -> Void

	init(group: ContactGroup, onGroupTapped: @escaping () -> Void) {
		// ViewModel initialization should not contain any intensive operations
		viewModel = ViewModel(group: group)
		self.onGroupTapped = onGroupTapped
	}

	var body: some View {
		DisclosureGroup(
			isExpanded: $isExpanded,
			content: {
				ForEach(viewModel.contacts) { contact in
					Button(
						action: {
							groupNavigation.path.append(.contactDetail(contact))
						},
						label: {
							Text(contact.displayName)
						}
					)
					.buttonStyle(PlainButtonStyle())
				}
			},
			label: {
				Button(
					action: onGroupTapped,
					label: {
						Text(viewModel.name)
							.fontWeight(.bold)
							.foregroundStyle(viewModel.color)
					}
				)
			}
		)
	}
}

extension GroupCardView {
	private final class ViewModel {
		private let group: ContactGroup
		let contacts: [Contact]

		var name: String {
			group.name
		}
		var color: Color {
			group.color
		}

		init(group: ContactGroup) {
			self.group = group
			@Dependency(\.contactsRepository) var contactsRepository
			contacts = group.contacts(from: contactsRepository).sorted()
		}
	}
}
