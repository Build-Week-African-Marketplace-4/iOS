//
//  Items.swift
//  AfricanMarketplace
//
//  Created by Patrick Millet on 1/6/20.
//  Copyright © 2020 Patrick Millet. All rights reserved.
//

import Foundation

struct Items: Codable {
    let id: Int
    let name: String
    let description: String
    let price: UInt
    let city: String
    let user_id: String
    let favorited: Bool
    let categories: [Category]
}

struct Category: Codable {
    let id: Int
    let type: String
    let item_id: String
}
