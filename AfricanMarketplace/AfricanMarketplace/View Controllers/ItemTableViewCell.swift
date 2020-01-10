//
//  ItemTableViewCell.swift
//  AfricanMarketplace
//
//  Created by Patrick Millet on 1/6/20.
//  Copyright © 2020 Patrick Millet. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    //MARK: - Outlets
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var itemCity: UILabel!
    @IBOutlet weak var itemCountry: UILabel!
    
    var itemRepresentation: CDItemRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    //MARK: - Methods
    
    private func updateViews() {
        guard let item = itemRepresentation else { return }
        itemName.text = item.name
        itemPrice.text = "\(item.price)"
        itemCity.text = item.city
        itemCountry.text = item.country
    }
    
}
