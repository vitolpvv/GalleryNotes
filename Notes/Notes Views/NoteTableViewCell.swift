//
//  NoteTableViewCell.swift
//  Notes
//
//  Created by VitalyP on 10/07/2019.
//  Copyright © 2019 vitalyp. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    var note: Note? {
        didSet{
            colorView.backgroundColor = note?.color
            titleLabel.text = note?.title
            contentLabel.text = note?.content
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        colorView.layer.borderColor = UIColor.black.cgColor
        colorView.layer.borderWidth = 1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
