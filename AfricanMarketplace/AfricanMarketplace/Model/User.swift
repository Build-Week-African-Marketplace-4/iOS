//
//  User.swift
//  AfricanMarketplace
//
//  Created by Patrick Millet on 1/6/20.
//  Copyright © 2020 Patrick Millet. All rights reserved.
//

import Foundation

struct User: Codable {
    let username: String
    let password: String
    let email: String
}

struct UserInfo: Codable {
    let id: Int
    let first_name: String
    let last_name: String
    let username: String
    let email: String
    let item: [Item]
}
