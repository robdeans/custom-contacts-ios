//
//  UserDefaults.swift
//  CustomContactsHelpers
//
//  Created by Robert Deans on 08/10/2024.
//  Copyright © 2023 RBD. All rights reserved.
//

import Foundation

@propertyWrapper
struct UserDefaults<T> {
	let key: String
	let defaultValue: T

	init(key: String, defaultValue: T) {
		self.key = key
		self.defaultValue = defaultValue
		if Foundation.UserDefaults.standard.object(forKey: key) == nil {
			Foundation.UserDefaults.standard.set(defaultValue, forKey: key)
		}
	}

	var wrappedValue: T {
		get { Foundation.UserDefaults.standard.object(forKey: key) as? T ?? defaultValue }
		set { Foundation.UserDefaults.standard.set(newValue, forKey: key) }
	}
}
