//
//  GalleryCollectionViewController.swift
//  Notes
//
//  Created by VitalyP on 12/07/2019.
//  Copyright © 2019 vitalyp. All rights reserved.
//

import UIKit
import Photos


// Галерея заметок.
// 
class GalleryCollectionViewController: UICollectionViewController {
    
    private let reuseIdentifier = "GalleryCell"
    private let itemsPerRow: CGFloat = 3
    
    private var gallery = FileGallery()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "ImageNoteCollectionViewCell", bundle: nil),
                                      forCellWithReuseIdentifier: reuseIdentifier)
        
        let loadOperation = LoadImageNotesOperation(gallery: gallery, backendQueue: OperationQueue(), dbQueue: OperationQueue())
        loadOperation.completionBlock = {
            OperationQueue.main.addOperation {
                self.collectionView.reloadData()
            }
        }
        OperationQueue().addOperation(loadOperation)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionViewLayout.invalidateLayout()
    }
    
    @IBAction func addPhotoTapped(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // Обработчик кнопки Edit
    @IBAction @objc func editButtonTapped() {
        isEditing = !isEditing
        switch isEditing {
        case true:
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editButtonTapped))
        default:
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
        }
        if let indexPaths = collectionView?.indexPathsForVisibleItems {
            for indexPath in indexPaths {
                if let cell = collectionView?.cellForItem(at: indexPath) as? ImageNoteCollectionViewCell {
                    cell.isEditing = isEditing
                }
            }
        }
        navigationItem.rightBarButtonItem?.isEnabled = !isEditing
    }
    
    // Количество заметок
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gallery.imageNotes.count
    }

    // Возвращает представление для ImageNote
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageNoteCollectionViewCell
        cell.image = gallery.imageNotes[indexPath.item].image() ?? UIImage(named: "noImage")
        cell.delegate = self
        cell.isEditing = isEditing
        return cell
    }
    
    // Обработчик выбора элемента
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        performSegue(withIdentifier: "ImageNotePagerSegue", sender: indexPath)
    }
    
    // Подготовка данных перед переходом на другой экран
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = sender as? IndexPath {
            let controller = segue.destination as! ImageNotePageViewController
            controller.index = indexPath.row
            controller.gallery = gallery
        }
    }
}

// Расширение для взаимодействия с UIImagePicker
extension GalleryCollectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let note = ImageNote(imagePath: (info[UIImagePickerController.InfoKey.imageURL] as! URL).path)
        let saveOperation = SaveImageNoteOperation(note: note, gallery: gallery, backendQueue: OperationQueue(), dbQueue: OperationQueue())
        saveOperation.completionBlock = {
            OperationQueue.main.addOperation {
                let insertedIndexPath = IndexPath(item: self.gallery.imageNotes.count - 1, section: 0)
                self.collectionView.insertItems(at: [insertedIndexPath])
            }
        }
        OperationQueue().addOperation(saveOperation)
        
        picker.dismiss(animated: true, completion: nil)
    }
}

// Расширение для расчета размера элемента
extension GalleryCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let paddingSpace = layout.sectionInset.left + layout.sectionInset.right + layout.minimumInteritemSpacing * (itemsPerRow - 1)
        let availableWidth = collectionView.bounds.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
}

// Расштрение для удаления компонента
extension GalleryCollectionViewController: ImageNoteCollectionViewCellDelegate {
    func delete(cell: ImageNoteCollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let removOperation = RemoveImageNoteOperation(note: gallery.imageNotes[indexPath.item], gallery: gallery, backendQueue: OperationQueue(), dbQueue: OperationQueue())
            removOperation.completionBlock = {
                OperationQueue.main.addOperation {
                    self.collectionView.deleteItems(at: [indexPath])
                }
            }
            OperationQueue().addOperation(removOperation)
        }
    }
}
