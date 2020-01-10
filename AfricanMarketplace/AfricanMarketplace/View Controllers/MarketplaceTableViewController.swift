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
    
    
     lazy var fetchedResultsController: NSFetchedResultsController<CDItem> = {
         let fetchRequest: NSFetchRequest<CDItem> = CDItem.fetchRequest()
         fetchRequest.sortDescriptors = [NSSortDescriptor(key: "favorite", ascending: true),
                                         NSSortDescriptor(key: "name", ascending: true)]
         let moc = CoreDataStack.shared.mainContext
         let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: "favorite", cacheName: nil)
         
         frc.delegate = self
         do {
             try frc.performFetch()
         } catch {
             print("Error fetching: \(error)")
         }
         return frc
     }()
    
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
        return fetchedResultsController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as? ItemTableViewCell else { return UITableViewCell() }

        cell.itemRepresentation = fetchedResultsController.object(at: indexPath)
        
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
        case "ItemDetailShowDegue":
            if let loginVC = segue.destination as? ItemsViewController {
                loginVC.apiController = apiController
            }
        default:
            return
        }
    }
}

extension MarketplaceTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
           tableView.beginUpdates()
       }
       
       func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
           tableView.endUpdates()
       }
       
       func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
           switch type {
           case .insert:
               tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
           case .delete:
               tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
           default:
               break
           }
       }

       func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
           switch type {
           case .insert:
               guard let newIndexPath = newIndexPath else { return }
               tableView.insertRows(at: [newIndexPath], with: .automatic)
           case .update:
               guard let indexPath = indexPath else { return }
               tableView.reloadRows(at: [indexPath], with: .automatic)
           case .move:
               guard let oldIndexPath = indexPath,
                   let newIndexPath = newIndexPath else { return }
               tableView.deleteRows(at: [oldIndexPath], with: .automatic)
               tableView.insertRows(at: [newIndexPath], with: .automatic)
           case .delete:
               guard let indexPath = indexPath else { return }
               tableView.deleteRows(at: [indexPath], with: .automatic)
           @unknown default:
               break
           }
       }
}
