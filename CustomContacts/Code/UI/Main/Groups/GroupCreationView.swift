//
//  GroupCreationView.swift
//  CustomContacts
//
//  Created by Robert Deans on 8/14/23.
//  Copyright © 2023 RBD. All rights reserved.
//

import CustomContactsModels
import Dependencies
import SwiftUI

private enum Layout {
	static let bottomViewHeight = CGFloat(40)
}

struct GroupCreationView: View, Identifiable {
	var id: String = {
		@Dependency(\.uuid) var uuid
		return uuid().uuidString
	}()

	@Dependency(\.contactsRepository) private var contactsRepository

	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss

	@State private var name = ""
	@State private var color = Color.random
	@State private(set) var selectedContactIDs = Set<Contact.ID>()

	@State private var contactSelectorView: ContactSelectorView?

	var body: some View {
		ZStack {
			VStack(spacing: 0) {
				Group {
					ColorPicker(
						selection: $color,
						supportsOpacity: true,
						label: {
							TextField(Localizable.Groups.Edit.groupName, text: $name)
								.autocorrectionDisabled()
								.foregroundStyle(color)
								.fontWeight(.semibold)
						}
					)
					.padding(.vertical, Constants.UI.Padding.default)

					Button(Localizable.Groups.Edit.addRemove) {
						contactSelectorView = ContactSelectorView(selectedContactIDs: selectedContactIDs) {
							selectedContactIDs = $0
						}
					}
				}
				.padding(Constants.UI.Padding.default)

				List {
					ForEach(
						selectedContactIDs
							.compactMap { contactsRepository.getContact($0) }
							.sorted(by: { $0.displayName < $1.displayName })
					) {
						Text($0.displayName)
					}
				}

				Spacer()
			}

			HStack {
				Button(
					action: { dismiss() },
					label: {
						Text(Localizable.Common.Actions.cancel)
							.frame(maxWidth: .infinity)
					}
				)

				Button(
					action: {
						let newGroup = ContactGroup(
							id: id,
							name: name,
							contactIDs: selectedContactIDs,
							colorHex: color.toHex ?? ""
						)
						modelContext.insert(newGroup)
						dismiss()
					},
					label: {
						Text(Localizable.Common.Actions.save)
							.frame(maxWidth: .infinity)
					}
				)
			}
			.frame(height: Layout.bottomViewHeight)
			.frame(maxHeight: .infinity, alignment: .bottom)
		}
		.sheet(item: $contactSelectorView) { $0 }
	}
}
