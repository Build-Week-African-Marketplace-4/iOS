//
//  ItemsViewController.swift
//  AfricanMarketplace
//
//  Created by Patrick Millet on 1/6/20.
//  Copyright © 2020 Patrick Millet. All rights reserved.
//

import UIKit

class ItemsViewController: UIViewController {

    //MARK: - Outlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    
    //MARK: - Properties
    
    var item: Item? {
        didSet {
            updateViews()
        }
    }
    
    var categoryObj: Category? {
        didSet {
            updateViews()
        }
    }
    
    var apiController: UserController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK: - Actions
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        guard let apiController = apiController,
            let name = nameTextField.text,
            let description = descriptionTextField.text,
            let price = priceTextField.text,
            let city = cityTextField.text,
            let country = countryTextField.text,
            let category = categoryTextField.text
            else { return }
        
        if var item = item, var unwrappedCategory = categoryObj {
            item.name = name
            item.description = description
            item.price = price
            item.city = city
            item.country = country
            unwrappedCategory.type = category
//            apiController.sendItemToServer(item: item)
        }
    }
    
    
    //MARK: - Methods
    
    private func updateViews() {
        nameTextField.text = item?.name
        descriptionTextField.text = item?.description
        priceTextField.text = item?.price
        cityTextField.text = item?.city
        countryTextField.text = item?.country
        
    }
}
