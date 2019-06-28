//
//  ViewController.swift
//  Notes
//
//  Created by VitalyP on 26/06/2019.
//  Copyright © 2019 vitalyp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var notes:[Note]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notes = FileNotebook().notes
        notes?.forEach {note in
            print(note)
        }
    }
}

