//
//  Items.swift
//  AfricanMarketplace
//
//  Created by Patrick Millet on 1/6/20.
//  Copyright © 2020 Patrick Millet. All rights reserved.
//

import Foundation

struct Item: Codable {
    var id: Int
    var name: String
    var description: String
    var price: String
    var city: String
    var country: String
    var user_id: String
    var favorited: Bool
    var categories: [Category]
}

struct Category: Codable {
    var id: Int
    var type: String
    var item_id: String
}
