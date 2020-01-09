//
//  Item+Convenience.swift
//  AfricanMarketplace
//
//  Created by Patrick Millet on 1/9/20.
//  Copyright © 2020 Patrick Millet. All rights reserved.
//

import Foundation
import CoreData

extension CDItem {
    //MARK - Properties
    
    var cdItemRepresentation: CDItemRepresentation? {
        guard let name = name,
              let description = itemDescription,
              let city = city,
              let country = country else { return nil }
        
        let itemPrice = price
        let didFavorite = favorite
        
        return CDItemRepresentation(name: name, description: description, price: itemPrice, city: city, country: country, favorite: didFavorite)
    }
    
    //MARK: - Convenience Inits
    
    convenience init(name: String, description: String, price: Double, city: String, country: String, favorite: Bool = false, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        self.name = name
        self.itemDescription = description
        self.price = price
        self.city = city
        self.country = country
        self.favorite = favorite
    }
}
