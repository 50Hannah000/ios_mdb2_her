//
//  MasterViewController.swift
//  IOS_Pokemon
//
//  Created by Hannah on 6/18/18.
//  Copyright © 2018 Hannah. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    var dataService = DataService()
    var pokemonObjects: [PokemonObject] = []
    var pokemons: [Pokemon] = []
    var page: Int = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchPokemons()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //
    private func fetchPokemons() {
    
        var count = 0
        do {
            count = try managedObjectContext!.count(for: Pokemon.fetchRequest())
            
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        if(count == 0) {
            print("count is 0, dus page ophalen")
            self.page = 1
        }
            print("page" + String(self.page))
            dataService.getPokemons(limit: 20, page: self.page) { (pokemon) in
            self.pokemonObjects.append(pokemon!)
            print(pokemon!)
            self.preparePokemons(pokemonObject: pokemon!)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func preparePokemons(pokemonObject: PokemonObject){
        let newPokemon = NSEntityDescription.insertNewObject(forEntityName: "Pokemon", into: managedObjectContext!) as! Pokemon
        
        newPokemon.name = (pokemonObject.forms[0] as Forms).name
        newPokemon.id = pokemonObject.id
        newPokemon.base_experience = pokemonObject.base_experience
        
        do {
            pokemons.append(newPokemon)
            print("appending pokes")
            if(self.page == 1){
            print("saving")
            try managedObjectContext!.save()
            }
        } catch {
            fatalError("Failure to save context: \(error)")
        }

    }
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                print(indexPath)
            let object = fetchedResultsController.object(at: indexPath)
                print("lalala", object)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemons.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let pokemon = fetchedResultsController.object(at: indexPath)
//        if(indexPath.row == (pokemons.count - 1)){
//            self.page = self.page + 1
//            self.fetchPokemons()
//        }
        configureCell(cell, withPokemon: pokemon)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
                
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func configureCell(_ cell: UITableViewCell, withPokemon pokemon: Pokemon) {
        cell.textLabel!.text = pokemon.name
    }

    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<Pokemon> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<Pokemon>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                configureCell(tableView.cellForRow(at: indexPath!)!, withPokemon: anObject as! Pokemon)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!)!, withPokemon: anObject as! Pokemon)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

}

