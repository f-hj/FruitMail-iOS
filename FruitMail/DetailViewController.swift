//
//  DetailViewController.swift
//  FruitMail
//
//  Created by Florian Hermouet-Joscht on 12/2/18.
//  Copyright © 2018 Florian Hermouet-Joscht. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    func configureView() {
        print("configureView detail")
        // Update the user interface for the detail item.
        if let name = folderName {
            if let label = detailDescriptionLabel {
                label.text = name
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    var folderState: String?
    var folderName: String? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

