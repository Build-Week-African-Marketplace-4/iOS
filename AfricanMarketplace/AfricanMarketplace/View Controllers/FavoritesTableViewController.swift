//
//  FavoritesTableViewController.swift
//  AfricanMarketplace
//
//  Created by Patrick Millet on 1/9/20.
//  Copyright © 2020 Patrick Millet. All rights reserved.
//

import UIKit
import CoreData

class FavoritesTableViewController: UITableViewController {
    

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

    
    //MARK: Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            self.clearsSelectionOnViewWillAppear = false
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            ItemController.sharedInstance.fetchItems { (result) in
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
        //MARK: Actions
        
    @IBAction func favoriteTapped(_ sender: UIButton) {
        guard let cell = sender.superview?.superview?.superview as? FavoritesTableViewCell else { return }

        if let indexPath = tableView.indexPath(for: cell) {
            ItemController.sharedInstance.hasFavorited(for:
                fetchedResultsController.object(at: indexPath))
            tableView.reloadData()
        }
    }
    
        
        // MARK: - Table view data source

        override func numberOfSections(in tableView: UITableView) -> Int {
            return fetchedResultsController.sections?.count ?? 1
        }

        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
        }

        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritesCell", for: indexPath) as? FavoritesTableViewCell else { return UITableViewCell()}

            cell.itemRepresentation = fetchedResultsController.object(at: indexPath)
            return cell
        }

       
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           //Change favorite Bool here with Star or something
        }
    }


extension FavoritesTableViewController: NSFetchedResultsControllerDelegate {
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
