//
//  DetailViewController.swift
//  IOS_Pokemon
//
//  Created by Hannah on 6/18/18.
//  Copyright © 2018 Hannah. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var BaseExpLabel: UILabel!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var IdLabel: UILabel!
    @IBOutlet weak var CatchButton: UIButton!
    
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = IdLabel {
                label.text = String(detail.id)
            }
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

    var detailItem: PokemonObject? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

