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
        
        return CDItemRepresentation(name: name, description: description, price: price, city: city, country: country, favorite: favorite, item_id: item_id)
    }
    
    //MARK: - Convenience Inits
    
    convenience init(name: String,
                     itemDescription: String,
                     price: Double,
                     city: String,
                     country: String,
                     favorite: Bool = false,
                     item_id: UUID = UUID(),
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        self.name = name
        self.itemDescription = itemDescription
        self.price = price
        self.city = city
        self.country = country
        self.favorite = favorite
        self.item_id = item_id
    }
    
    @discardableResult convenience init?(itemRepresentation: CDItemRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {

        guard let identifier = itemRepresentation.item_id,
            let favorited = itemRepresentation.favorite else { return nil }
        
        self.init(name: itemRepresentation.name,
                  itemDescription: itemRepresentation.description,
                  price: itemRepresentation.price,
                  city: itemRepresentation.city,
                  country: itemRepresentation.country,
                  favorite: favorited,
                  item_id: identifier)
    }
}
