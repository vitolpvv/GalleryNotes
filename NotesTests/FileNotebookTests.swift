//
//  FileNotebookTest.swift
//  NotesTests
//
//  Created by VitalyP on 28/06/2019.
//  Copyright © 2019 vitalyp. All rights reserved.
//

import XCTest
@testable import Notes

class FileNotebookTests: XCTestCase {
    
    func testAddNote() {
        // Load Notes
        var fileNotebook: FileNotebook? = FileNotebook()
        // Get Notes count
        let notesInitCount = fileNotebook!.notes.count
        // Add Note
        fileNotebook!.add(Note(title: "Title", content: "Content", importance: .normal, liveTill: nil))
        // Save Notes
        fileNotebook = nil
        // Load Notes again
        fileNotebook = FileNotebook()
        // Check Notes count increases by one
        XCTAssertEqual(fileNotebook!.notes.count, notesInitCount + 1)
    }
    
    func testExistedNoteReplace() {
        // Load Notes
        var fileNotebook: FileNotebook? = FileNotebook()
        // Get Notes count
        let notesInitCount = fileNotebook!.notes.count
        // Get last Note
        let noteFromStore = fileNotebook!.notes.last!
        // Add new Note with same uid
        fileNotebook!.add(Note(uid: noteFromStore.uid, title: "New title", content: "New content", color: UIColor.red, importance: .high, liveTill: Date()))
        // Save Notes
        fileNotebook = nil
        // Load Notes again
        fileNotebook = FileNotebook()
        // Get note by uid
       let note = fileNotebook!.notes.first(where: {n in
            n.uid == noteFromStore.uid
        })
        // Check Notes count the same
        XCTAssertEqual(notesInitCount, fileNotebook!.notes.count)
        // Check Note exists
        XCTAssertNotNil(note)
        // Check Note title
        XCTAssertEqual(note!.title, "New title")
        // Check Note content
        XCTAssertEqual(note!.content, "New content")
        
    }
    
    func testRemoveNote() {
        // Load Notes
        var fileNotebook: FileNotebook? = FileNotebook()
        // Get Notes count
        let notesInitCount = fileNotebook!.notes.count
        // Remove last Note
        fileNotebook!.remove(with: fileNotebook!.notes.last!.uid)
        // Save Notes
        fileNotebook = nil
        // Load Notes again
        fileNotebook = FileNotebook()
        // Check Notes count decreases by one
        XCTAssertEqual(fileNotebook!.notes.count, notesInitCount - 1)
    }
}
