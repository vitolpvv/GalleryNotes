//
//  NotesViewController.swift
//  Notes
//
//  Created by VitalyP on 10/07/2019.
//  Copyright © 2019 vitalyp. All rights reserved.
//

import UIKit
import CoreData

// Таблица заметок
class NotesTableViewController: UIViewController {
    private let noteCellIdentifier = "NoteCell"
    private let notesDataSource = DBNotebook()
    private let activityView = UIActivityIndicatorView(style: .gray)
    private var activityBarButton: UIBarButtonItem?
    
    @IBOutlet var tableView: UITableView!
    
    var persistentContainer: NSPersistentContainer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard persistentContainer != nil else {
            fatalError("This view needs a persistent container")
        }
        
        tableView.register(UINib(nibName: "NoteTableViewCell", bundle: nil),
                                forCellReuseIdentifier: noteCellIdentifier)
        activityBarButton = UIBarButtonItem(customView: activityView)
        activityView.startAnimating()
        navigationItem.rightBarButtonItems?.append(activityBarButton!)
        
        let loadOperation = LoadNotesOperation(notebook: notesDataSource,
                                               backendQueue: OperationQueue(),
                                               dbQueue: OperationQueue(),
                                               context: persistentContainer.newBackgroundContext())
        loadOperation.completionBlock = {
            OperationQueue.main.addOperation {
                self.tableView.reloadData()
                self.navigationItem.rightBarButtonItems?.removeAll { item in
                    self.activityBarButton!.isEqual(item)
                }
            }
        }
        OperationQueue().addOperation(loadOperation)
    }
    
    // Обработчик кнопки Edit
    @IBAction
    @objc private func editNotesClicked() {
        tableView.isEditing = !tableView.isEditing
        switch tableView.isEditing {
        case true:
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editNotesClicked))
        default:
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editNotesClicked))
        }
        navigationItem.rightBarButtonItem?.isEnabled = !tableView.isEditing
    }
    
    // Подготовка данных перед переходом
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let indexPath = sender as? IndexPath {
            let destController = segue.destination as! EditNoteViewController
            destController.note = notesDataSource.notes[indexPath.row]
        }
    }
}

// Расширение для создание ячеек таблицы
extension NotesTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesDataSource.notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: noteCellIdentifier,
                                                      for: indexPath) as! NoteTableViewCell
        if indexPath.row < notesDataSource.notes.count {
            cell.note = notesDataSource.notes[indexPath.row]
        }
        
        return cell
    }
}

// Расширение для обновления таблици при изменении данных
extension NotesTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            navigationItem.rightBarButtonItems?.append(activityBarButton!)
            let removeOperation = RemoveNoteOperation(note: notesDataSource.notes[indexPath.row],
                                                      notebook: notesDataSource,
                                                      backendQueue: OperationQueue(),
                                                      dbQueue: OperationQueue(),
                                                      context: persistentContainer.newBackgroundContext())
            removeOperation.completionBlock = {
                OperationQueue.main.addOperation {
                    self.navigationItem.rightBarButtonItems?.removeAll { item in
                        self.activityBarButton!.isEqual(item)
                    }
                    self.tableView.beginUpdates()
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.tableView.endUpdates()
                }
            }
            OperationQueue().addOperation(removeOperation)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "EditNoteSegue", sender: indexPath)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    @IBAction func unwindToNotesView(_ unwindSegue: UIStoryboardSegue) {
        if let sourceController = unwindSegue.source as? EditNoteViewController, let note = sourceController.note {
            navigationItem.rightBarButtonItems?.append(activityBarButton!)
            switch notesDataSource.indexOf(note) {
            case .none:
                let saveOperation = SaveNoteOperation(note: note,
                                                      notebook: notesDataSource,
                                                      backendQueue: OperationQueue(),
                                                      dbQueue: OperationQueue(),
                                                      context: persistentContainer.newBackgroundContext())
                saveOperation.completionBlock = {
                    OperationQueue.main.addOperation {
                        self.tableView.beginUpdates()
                        self.tableView.insertRows(at: [IndexPath(row: self.notesDataSource.notes.count - 1, section: 0)], with: .automatic)
                        self.tableView.endUpdates()
                        self.navigationItem.rightBarButtonItems?.removeAll { item in
                            self.activityBarButton!.isEqual(item)
                        }
                    }
                }
                OperationQueue().addOperation(saveOperation)
            case let index?:
                let saveOperation = SaveNoteOperation(note: note,
                                                      notebook: notesDataSource,
                                                      backendQueue: OperationQueue(),
                                                      dbQueue: OperationQueue(),
                                                      context: persistentContainer.newBackgroundContext())
                saveOperation.completionBlock = {
                    OperationQueue.main.addOperation {
                        self.tableView.beginUpdates()
                        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                        self.tableView.endUpdates()
                        self.navigationItem.rightBarButtonItems?.removeAll { item in
                            self.activityBarButton!.isEqual(item)
                        }
                    }
                }
                OperationQueue().addOperation(saveOperation)
            }
        }
    }
}
