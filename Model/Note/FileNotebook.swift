//
//  FileNotebook.swift
//  
//
//  Created by VitalyP on 21/06/2019.
//
import UIKit
import CocoaLumberjack

public class FileNotebook {
    // String constants
    private enum Str {
        static let fileName = "notes.json"
        static let jsonRoot = "notes"
    }
    
    // Notes collection
    public private(set) var notes = [Note]()
    
    // Load Notes on initialization
    init() {
        #if TEMPNOTES
        add(Note(title: "Note 1", content: "Content of note 1", importance: Note.Importance.low, destroyDate: nil))
        add(Note(title: "Note 2", content: "Content of note 2", importance: Note.Importance.low, destroyDate: Date()))
        add(Note(title: "Note 3", content: "Content of note 3", color: UIColor.yellow, importance: Note.Importance.low, destroyDate: Date()))
        #endif
        load()
        
    }
    
    // Save Notes on deinitialization
    deinit { save() }
    
    // Add Note (Replace if Note with same uid exists)
    public func add(_ note: Note) {
        switch (index(of: note)) {
        case let index?:
            notes[index] = note
            DDLogInfo("Note with uid=\(note.uid) replaced by \(note).")
        case .none:
            notes.append(note)
            DDLogInfo("Note with uid=\(note.uid) appended.")
        }
        save()
    }
    
    // Find Note index by uid
    public func index(of note: Note) -> Int? {
        return notes.firstIndex(where: { $0.uid == note.uid })
    }
    
    // Remove Note by uid
    public func remove(with uid: String) {
        notes.removeAll(where: { $0.uid == uid })
        save()
        DDLogInfo("Note with uid=\(uid) removed.")
    }
    
    // Remove Note by index
    public func remove(with index: Int) {
        notes.remove(at: index)
        save()
        DDLogInfo("Note with index=\(index) removed.")
    }
    
    // Get file url
    private let fileUrl = {() -> URL? in
        #if TEMPNOTES
        return FileManager.default.temporaryDirectory.appendingPathComponent(Str.fileName)
        #else
        return FileManager.default.urls(for: .documentDirectory,
                                        in: .userDomainMask).first?.appendingPathComponent(Str.fileName)
        #endif
    }
    
    // Seve Note to file
    private func save() {
        // Create dictionary of Notes
        var items = [[String: Any]]()
        self.notes.forEach { note in
            items.append(note.json)
        }
        var dict = [String: Any]()
        dict[Str.jsonRoot] = items
        
        // First: Try create json
        // If success: Get file url, check file existence and try create if not
        // If success: Try write json to file
        guard let json = try? JSONSerialization.data(withJSONObject: dict, options: []) else {
            DDLogError("Notes save: Data serialization error.")
            return
        }
        guard let file = self.fileUrl(),
            (FileManager.default.fileExists(atPath: file.path) ||
                FileManager.default.createFile(atPath: file.path, contents: nil, attributes: nil)) else {
                    DDLogError("Notes save: File do not accessilbe.")
                    return
        }
        guard ((try? json.write(to: file)) != nil) else {
            DDLogError("Notes save: Writing file error.")
            return
        }
    }
    
    // Load Notes from file
    private func load() {
        // First get file url
        // If success: Try get data
        // If success: Try create json
        // If success: Parse each Note
        guard let file = self.fileUrl() else {
            DDLogError("Notes load: File do not accessible.")
            return
        }
        guard let data = try? Data(contentsOf: file) else {
            DDLogError("Notes load: Reading file error.")
            return
        }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: [[String: Any]]] else {
            DDLogError("Notes load: Data deserialization error.")
            return
        }
        json[Str.jsonRoot]?.forEach { item in
            switch Note.parse(json: item) {
            case let note?: notes.append(note)
            default: break
                
            }
        }
    }
}
