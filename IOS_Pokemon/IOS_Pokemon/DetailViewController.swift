//
//  DetailViewController.swift
//  IOS_Pokemon
//
//  Created by Hannah on 6/18/18.
//  Copyright © 2018 Hannah. All rights reserved.
//
import Foundation
import UIKit
import CoreData

class DetailViewController: UIViewController {

    @IBOutlet weak var BaseExpLabel: UILabel!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var IdLabel: UILabel!
    @IBOutlet weak var CatchButton: UIButton!
    
    var pokemonToCatch: Pokemon!
    var managedObjectContext: NSManagedObjectContext? = nil
    var caught: Bool = false
    
    func configureView() {
    // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = IdLabel {
                label.text = String(detail.id)
            }
            if let name = NameLabel {
                name.text = detail.name
            }
            if let baseExp = BaseExpLabel {
                baseExp.text = String(detail.base_experience)
            }
        }
        pokemonToCatch = detailItem!
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showCaughtPokemons" {
            let controller = (segue.destination as! UITableViewController) as! CaughtPokemonsTableTableViewController
            controller.managedObjectContext = managedObjectContext
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func catchPokemon(_ sender: UIButton) {
        let exists = checkPokemonExists(id: Int(pokemonToCatch.id))
        if(exists) {
            var alert: UIAlertController? = nil
            alert = UIAlertController(title: "Noooo!", message: "You've caught " + pokemonToCatch.name! + " already, u cant catch him again!", preferredStyle: .alert)
            alert!.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert!, animated: true)
            return
        }
        
        print("catch pkemon aangeroenpen")
        print(self)
        var chance = 75
        
        let baseExp = pokemonToCatch.base_experience
        chance = baseExp > 75 ? chance - 30 : chance;
        chance = baseExp > 125 ? chance - 20 : chance;
        chance = baseExp > 200 ? chance - 10 : chance;
        
        if(Int(arc4random_uniform(100)) > chance) {
            displayCatch()
            return
        }
        let caughtPokemon = NSEntityDescription.insertNewObject(forEntityName: "CaughtPokemon", into: managedObjectContext!) as! CaughtPokemon
        caughtPokemon.name = pokemonToCatch.name
        caughtPokemon.id = pokemonToCatch.id
        caughtPokemon.base_experience = pokemonToCatch.base_experience
        do {
            try managedObjectContext!.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        caught = true
        displayCatch()
    }
    
    func checkPokemonExists(id: Int) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CaughtPokemon")
        
        fetchRequest.predicate = NSPredicate(format: "id = %d", id)
        var results: [NSManagedObject] = []
        
        do {
            results =  try managedObjectContext?.fetch(fetchRequest) as! [NSManagedObject]
 
        } catch {
            print(error)
        }
         return results.count > 0
    }
    
    private func displayCatch(){
        var alert: UIAlertController? = nil
        if(caught) {
            alert = UIAlertController(title: "YEAAASSSSCHH!", message: "You've caught a " + pokemonToCatch.name! + " !", preferredStyle: .alert)
            alert!.addAction(UIAlertAction(title: "Ok", style: .default, handler: {action in self.performSegue(withIdentifier: "showCaughtPokemons", sender: self)}))
        } else {
            alert = UIAlertController(title: "OHNOOOOO!", message: pokemonToCatch.name! + " got away!", preferredStyle: .alert)
            alert!.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        }
        self.present(alert!, animated: true)
    }
  

    var detailItem: Pokemon? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

