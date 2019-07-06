//
//  NotesTests.swift
//  NotesTests
//
//  Created by VitalyP on 26/06/2019.
//  Copyright © 2019 vitalyp. All rights reserved.
//

import XCTest
@testable import Notes

class NotesTests: XCTestCase {
    
    // Check Note uid generation
    func testDefaultNoteUidGeneration() {
        // Create Note with no uid provided
        let note = Note(title: "Title", content: "Content", importance: .low, destroyDate: nil)
        // Check uid not empty
        XCTAssertNotNil(note.uid)
        XCTAssertGreaterThan(note.uid, "")
    }
    
    // Check default Note color
    func testDefaultNoteColorIsWhite() {
        // Create Note with no color provided
        let note = Note(title: "Title", content: "Content", importance: .low, destroyDate: nil)
        // Check Note color is WHITE
        XCTAssertEqual(note.color, UIColor.white)
    }
    
    // Check json dictionary contains required fields (uid, title, content)
    func testNoteJsonContainsRequiredFields() {
        let noteJson = Note(title: "Title", content: "Content", importance: .normal, destroyDate: nil).json
        XCTAssertTrue(noteJson.keys.contains(Note.JsonKeys.uid))
        XCTAssertTrue(noteJson.keys.contains(Note.JsonKeys.title))
        XCTAssertTrue(noteJson.keys.contains(Note.JsonKeys.content))
    }
    
    // Check json dictionary have no color field if Note color is WHITE
    func testNoteJsonMissedDefaultColor() {
        let noteJson = Note(title: "Title", content: "Content", importance: .normal, destroyDate: nil).json
        XCTAssertFalse(noteJson.keys.contains(Note.JsonKeys.color))
    }
    
    // Check json dictionary have no importance field if Note importance is NORMAL
    func testNoteJsonMissedNormalImportance() {
        let noteJson = Note(title: "Title", content: "Content", importance: .normal, destroyDate: nil).json
        XCTAssertFalse(noteJson.keys.contains(Note.JsonKeys.importance))
    }
    
    // Check json dictionary have no destroy_date field if date no provided (nil)
    func testNoteJsonMissedDateNil() {
        let noteJson = Note(title: "Title", content: "Content", importance: .normal, destroyDate: nil).json
        XCTAssertFalse(noteJson.keys.contains(Note.JsonKeys.destroyDate))
    }
    
    // Check Note -> Json -> Note conversion
    func testNoteToJsonToNoteConversion() {
        let note1 = Note(uid: "12345", title: "Title", content: "Content", color: UIColor.red, importance: .high, destroyDate: nil)
        let note2 = Note.parse(json: note1.json)
        XCTAssertNotNil(note2)
        XCTAssertEqual(note1.uid, note2?.uid)
        XCTAssertEqual(note1.title, note2?.title)
        XCTAssertEqual(note1.content, note2?.content)
        XCTAssertEqual(note1.color, note2?.color)
        XCTAssertEqual(note1.importance, note2?.importance)
        XCTAssertEqual(note1.destroyDate, note2?.destroyDate)
    }

}
