//
//  MarketplaceTableViewController.swift
//  AfricanMarketplace
//
//  Created by Patrick Millet on 1/6/20.
//  Copyright © 2020 Patrick Millet. All rights reserved.
//

import UIKit
import CoreData

class MarketplaceTableViewController: UITableViewController, UISearchBarDelegate {

    
    //MARK: - Properties
    
    private var itemNames: [String] = []
    let apiController = ItemController()
    
    //MARK: - Outlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if apiController.token == nil {
            performSegue(withIdentifier: "LoginSegue", sender: self)
        } else {
            apiController.fetchItems { (result) in
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    

    @IBAction func refresh(_ sender: Any) {
        apiController.fetchItems() { _ in
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    func searchBarButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
        
        apiController.searchForItem(with: searchTerm) { (error) in
//            guard let error == nil else { return }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return apiController.searchedItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as? ItemTableViewCell else { return UITableViewCell() }

        cell.itemRepresentation = apiController.searchedItems[indexPath.row]
        
        return cell
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "LoginSegue":
            if let loginVC = segue.destination as? LoginScreenViewController {
                loginVC.apiController = apiController
            }
        case "AddItemShowSegue":
            if let loginVC = segue.destination as? ItemsViewController {
                loginVC.apiController = apiController
            }
        case "ItemDetailShowSegue":
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            if let loginVC = segue.destination as? ItemsViewController {
                loginVC.apiController = apiController
                loginVC.item = apiController.searchedItems[indexPath.row]
            }
        default:
            return
        }
    }
}

