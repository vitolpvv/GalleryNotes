//
//  NotesViewController.swift
//  Notes
//
//  Created by VitalyP on 10/07/2019.
//  Copyright © 2019 vitalyp. All rights reserved.
//

import UIKit

// Таблица заметок
class NotesTableViewController: UIViewController {
    private let noteCellIdentifier = "NoteCell"
    private var notesDataSource = FileNotebook()
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "NoteTableViewCell", bundle: nil),
                                forCellReuseIdentifier: noteCellIdentifier)
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
        
        cell.note = notesDataSource.notes[indexPath.row]
        
        return cell
    }
}

// Расширение для обновления таблици при изменении данных
extension NotesTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notesDataSource.remove(with: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "EditNoteSegue", sender: indexPath)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    @IBAction func unwindToNotesView(_ unwindSegue: UIStoryboardSegue) {
        if let sourceController = unwindSegue.source as? EditNoteViewController, let note = sourceController.note {
            switch notesDataSource.index(of: note) {
            case .none:
                notesDataSource.add(note)
                tableView.beginUpdates()
                tableView.insertRows(at: [IndexPath(row: notesDataSource.notes.count - 1, section: 0)], with: .automatic)
                tableView.endUpdates()
            case let index?:
                notesDataSource.add(note)
                tableView.beginUpdates()
                tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                tableView.endUpdates()
            }
        }
    }
}
