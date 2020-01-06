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
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    //MARK: - Properties
    
    var item: Item? {
        didSet {
            updateViews()
        }
    }
    
    var apiController: UserController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK: - Actions
    @IBAction func saveTapped(_ sender: Any) {
        guard let apiController = apiController,
            let name = nameTextField.text,
            let description = descriptionTextField.text,
            let price = priceTextField.text,
            let city = cityTextField.text,
            let country = countryTextField.text,
            let category = categoryPicker.
    }
    
    
    //MARK: - Methods
    
    private func updateViews() {
        nameTextField.text = item?.name
        descriptionTextField.text = item?.description
        priceTextField.text = String(item?.price)
        cityTextField.text = item?.city
        countryTextField.text = item?.country
        
    }
}

extension ItemsViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        <#code#>
    }
}
