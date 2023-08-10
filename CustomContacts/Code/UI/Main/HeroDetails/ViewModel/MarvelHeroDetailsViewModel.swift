//
//  MarvelHeroDetailsViewModel.swift
//  CustomContacts
//
//  Created by Vinay Kharb on 02/05/23.
//  Copyright © 2023 Fueled. All rights reserved.
//

import Combine
import CustomContactsAPIKit

final class MarvelHeroDetailsViewModel: ObservableObject {
	@Published private(set) var character: MarvelCharacter

	init(character: MarvelCharacter) {
		self.character = character
	}
}
