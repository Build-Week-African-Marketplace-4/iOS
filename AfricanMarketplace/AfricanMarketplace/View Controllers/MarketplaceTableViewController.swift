//
//  MarketplaceTableViewController.swift
//  AfricanMarketplace
//
//  Created by Patrick Millet on 1/6/20.
//  Copyright © 2020 Patrick Millet. All rights reserved.
//

import UIKit

class MarketplaceTableViewController: UITableViewController {

    
    //MARK: - Properties
    
    private var itemNames: [String] = []
    let apiController = UserController()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if apiController.authToken == nil {
            performSegue(withIdentifier: "LoginSegue", sender: self)
        } else {
            apiController.fetchItems { (result) in
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return apiController.items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as? ItemTableViewCell else { return UITableViewCell() }

        cell.item = apiController.items[indexPath.row]
        
        return cell
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ItemDetailShowSegue" {
            if let detailVC = segue.destination as? ItemsViewController,
                let indexPath = tableView.indexPathForSelectedRow {
                detailVC.apiController = apiController
            }
        }
    
    }
    

}
