//
//  ImageNoteCollectionViewCell.swift
//  Notes
//
//  Created by VitalyP on 12/07/2019.
//  Copyright © 2019 vitalyp. All rights reserved.
//

import UIKit

// Протокол для уведомления о необходимости удалить элемент
protocol ImageNoteCollectionViewCellDelegate: class {
    func delete(cell: ImageNoteCollectionViewCell)
}

// Представление элемента UICollectionView
class ImageNoteCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteButton: UIVisualEffectView!
    
    weak var delegate: ImageNoteCollectionViewCellDelegate?
    
    var image: UIImage? {
        didSet{
            imageView.image = image
        }
    }
    
    var isEditing: Bool = false {
        didSet{
            deleteButton.isHidden = !isEditing
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 0.5
        
        deleteButton.layer.cornerRadius = deleteButton.bounds.width / 2.0
        deleteButton .isHidden = !isEditing
    }

    // Обработчик кнопки Delete
    @IBAction func deleteButtonTapped(_ sender: Any) {
        delegate?.delete(cell: self)
    }
}
