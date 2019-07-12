//
//  ImageNoteCollectionViewCell.swift
//  Notes
//
//  Created by VitalyP on 12/07/2019.
//  Copyright © 2019 vitalyp. All rights reserved.
//

import UIKit

class ImageNoteCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 0.5
    }

}
