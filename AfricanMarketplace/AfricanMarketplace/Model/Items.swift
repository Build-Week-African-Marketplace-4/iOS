//
//  Items.swift
//  AfricanMarketplace
//
//  Created by Patrick Millet on 1/6/20.
//  Copyright © 2020 Patrick Millet. All rights reserved.
//

import Foundation

struct Item: Codable {
    var name: String
    var description: String
    var price: Int
    var city: String
    var country: String
    var user_id: Int? = 1
}
