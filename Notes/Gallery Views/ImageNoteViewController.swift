//
//  ImageNoteViewController.swift
//  Notes
//
//  Created by VitalyP on 12/07/2019.
//  Copyright © 2019 vitalyp. All rights reserved.
//

import UIKit

// Представление элемента в листалке
class ImageNoteViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage?
    var index: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
}
