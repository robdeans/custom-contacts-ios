//
//  GroupDetailView.swift
//  CustomContacts
//
//  Created by Robert Deans on 8/14/23.
//  Copyright © 2023 RBD. All rights reserved.
//

import CustomContactsModels
import Dependencies
import SwiftData
import SwiftUI

struct GroupDetailView: View {
	@Dependency(\.contactsRepository) private var contactsRepository
	@Bindable private(set) var group: ContactGroup

	@State private var isEditing = false
	private var color: Binding<Color> {
		Binding(
			get: { group.color },
			set: { group.colorHex = $0.toHex ?? "" }
		)
	}
	@State private var contactSelectorView: ContactSelectorView?

	var body: some View {
		ZStack {
			contentView
			addRemoveContactsButton
		}
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button(
					isEditing
					? Localizable.Common.Actions.save
					: Localizable.Common.Actions.edit
				) {
					withAnimation {
						isEditing.toggle()
					}
				}
				.padding(Constants.UI.Padding.small)
				.background(Color.white.opacity(0.2))
				.cornerRadius(15)
			}
		}
		.toolbarBackground(group.color, for: .navigationBar)
		.toolbarBackground(.visible, for: .navigationBar)
		.toolbarColorScheme(.dark, for: .navigationBar)
		.navigationTitle(group.name)
		.sheet(item: $contactSelectorView) { $0 }
	}

	private var contentView: some View {
		VStack {
			if isEditing {
				ColorPicker(
					selection: color,
					label: {
						TextField(group.name, text: $group.name)
							.foregroundStyle(group.color)
							.fontWeight(.semibold)
					}
				)
				.padding(Constants.UI.Padding.default)
			}

			List {
				ForEach(group.contacts(from: contactsRepository).sorted()) {
					Text($0.displayName)
				}
			}
			.padding(.top, Constants.UI.Padding.default)

			Spacer()
		}
		.ignoresSafeArea(edges: [.bottom])
	}

	private var addRemoveContactsButton: some View {
		Button(
			action: {
				contactSelectorView = ContactSelectorView(selectedContactIDs: group.contactIDs) {
					// TODO: only save/persist when `Done` is tapped? SwiftData updates immediately
					group.contactIDs = $0
				}
			},
			label: {
				Text(Localizable.Groups.Edit.addRemove)
					.fontWeight(.semibold)
					.foregroundStyle(Color.white)
					.padding()
					.background(group.color)
					.cornerRadius()
			}
		)
		.frame(maxHeight: .infinity, alignment: .bottom)
		.padding(.bottom, Constants.UI.Padding.default)
		.opacity(isEditing ? 1 : 0)
	}
}

#Preview {
	MainActor.assumeIsolated {
		let container = previewContainer
		return NavigationStack {
			GroupDetailView(
				group: .mock
			)
		}
			.modelContainer(container)
	}
}

@MainActor
private let previewContainer: ModelContainer = {
	do {
		let container = try ModelContainer(for: ContactGroup.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
		container.mainContext.insert(ContactGroup.mock)
		return container
	} catch {
		fatalError("Failed to create container")
	}
}()
