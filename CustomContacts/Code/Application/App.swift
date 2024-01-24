//
//  App.swift
//  CustomContacts
//
//  Created by Robert Deans on 08/10/2024.
//  Copyright © 2023 RBD. All rights reserved.
//

import CustomContactsModels
import SwiftUI

@main
struct CustomContactsApp: App {
	var body: some Scene {
		WindowGroup {
			RootView()
				.modelContainer(for: ContactGroup.self)
		}
	}
}
