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
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    //MARK: - Properties
    
    var item: CDItemRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    var apiController: ItemController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    //MARK: - Actions
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        
        guard let priceString = priceTextField.text else { return }
        guard let apiController = apiController,
            let name = nameTextField.text,
            let price = NumberFormatter().number(from: priceString),
            let city = cityTextField.text,
            let country = countryTextField.text,
            let item_id = item?.item_id,
            let description = descriptionTextField.text
            else { return }
        
        let newItem = CDItemRepresentation(name: name, description: description, price: Double(truncating: price), city: city, country: country, favorite: false, item_id: item_id)
        
        apiController.add(item: newItem, completion: { error in
            if let error = error {
                print("Error adding new item \(error)")
            }
        })
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    //MARK: - Methods
    
    private func updateViews() {
        
        guard let item = item,
                isViewLoaded else { return }
        saveButton.isEnabled = false
        nameTextField.text = item.name
        descriptionTextField.text = item.description
        priceTextField.text = "\(item.price)"
        cityTextField.text = item.city
        countryTextField.text = item.country
        
    }
}
