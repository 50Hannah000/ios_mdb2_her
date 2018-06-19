//
//  Pokemon.swift
//  IOS_Pokemon
//
//  Created by Hannah on 6/18/18.
//  Copyright © 2018 Hannah. All rights reserved.
//

import Foundation
import CoreData

struct PokemonObject: Decodable {
    let id: Int32
    let forms: [Forms]
    let base_experience: Int32
    
    init() {
        self.forms = [Forms(name: "")]
        self.id = 0
        self.base_experience = 0
    }
}

struct Forms: Decodable {
    let name: String
}

