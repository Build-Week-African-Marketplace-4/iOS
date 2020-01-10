//
//  FavoritesTableViewCell.swift
//  AfricanMarketplace
//
//  Created by Patrick Millet on 1/9/20.
//  Copyright © 2020 Patrick Millet. All rights reserved.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {

    //MARK: - Outlets
    
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    
    //MARK: - Properties

  var itemRepresentation: CDItem? {
        didSet {
            updateViews()
        }
    }
    
    //MARK: - Methods
    
    private func updateViews() {
        guard let item = itemRepresentation else { return }
        itemName.text = item.name
        itemPrice.text = "\(item.price)"
        
        if let favorited = itemRepresentation?.favorite {
            if favorited == true {
                favoriteButton.isHighlighted = true
            } else {
                favoriteButton.isHighlighted = false
            }
        }
        
    }
}
