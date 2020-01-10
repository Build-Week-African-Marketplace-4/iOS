//
//  CDItemRepresentation.swift
//  AfricanMarketplace
//
//  Created by Patrick Millet on 1/9/20.
//  Copyright © 2020 Patrick Millet. All rights reserved.
//

import Foundation

struct CDItemRepresentation: Codable, Equatable {
    var name: String
    var description: String
    var price: Double
    var city: String
    var country: String
    var favorite: Bool?
    var item_id: UUID?
}

struct CDItemRepresentations: Codable {
    let results: [CDItemRepresentation]
}
