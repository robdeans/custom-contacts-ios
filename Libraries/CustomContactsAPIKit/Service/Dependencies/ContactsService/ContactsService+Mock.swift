//
//  ContactsService+Mock.swift
//  CustomContacts
//
//  Created by Robert Deans on 9/11/23.
//  Copyright © 2023 RBD. All rights reserved.
//

import CustomContactsModels

extension ContactsService {
	public static var previewValue: Self {
		Self(
			fetchContacts: {
				Contact.mockArray
			},
			requestPermissions: {
				true
			}
		)
	}
	public static var testValue: ContactsService { .previewValue }
}
