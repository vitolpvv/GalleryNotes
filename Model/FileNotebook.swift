//
//  FileNotebook.swift
//  
//
//  Created by VitalyP on 21/06/2019.
//
import UIKit

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
        add(Note(title: "Note 1", content: "Content of note 1", importance: Note.Importance.low, liveTill: nil))
        add(Note(title: "Note 2", content: "Content of note 2", importance: Note.Importance.low, liveTill: Date()))
        add(Note(title: "Note 3", content: "Content of note 3", color: UIColor.yellow, importance: Note.Importance.low, liveTill: Date()))
        #endif
        load()
        
    }
    
    // Save Notes on deinitialization
    deinit { save() }
    
    // Add Note (Replace if Note with same uid exists)
    public func add(_ note: Note) {
        switch (notes.firstIndex(where: { $0.uid == note.uid })) {
        case let index?: notes[index] = note
        case .none: notes.append(note)
        }
    }
    
    // Remove Note by uid
    public func remove(with uid: String) {
        notes.removeAll(where: { $0.uid == uid })
    }
    
    // Get file url
    private let fileUrl = {() -> URL? in
        #if TEMPNOTES
        return FileManager.default.temporaryDirectory.appendingPathComponent(Str.fileName)
        #else
        return FileManager.default.urls(for: .cachesDirectory,
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
        // If success: Get file url
        // If success: Check file existence and try create if not
        // If success: Try write json to file
        if let json = try? JSONSerialization.data(withJSONObject: dict, options: []),
            let file = self.fileUrl(),
            (FileManager.default.fileExists(atPath: file.path) ||
                FileManager.default.createFile(atPath: file.path, contents: nil, attributes: nil)){
            
            try? json.write(to: file)
        }
    }
    
    // Load Notes from file
    private func load() {
        // First get file url
        // If success: Try get data
        // If success: Try create json
        // If success: Parse each Note
        if let file = self.fileUrl(),
            let data = try? Data(contentsOf: file),
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: [[String: Any]]] {
            
            json[Str.jsonRoot]?.forEach { item in
                switch Note.parse(json: item) {
                case let note?: self.add(note)
                default: break
                }
            }
        }
    }
}