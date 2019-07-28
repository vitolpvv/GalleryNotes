//
//  FileGallery.swift
//  Notes
//
//  Created by VitalyP on 12/07/2019.
//  Copyright © 2019 vitalyp. All rights reserved.
//

import UIKit
import CocoaLumberjack

// Хранилище ImageNote
class FileGallery {
    // String constants
    private enum Str {
        static let fileName = "gallery.json"
        static let jsonRoot = "gallery"
    }
    
    public private(set) var imageNotes = [ImageNote]()
    
    public func add(_ imageNote: ImageNote) {
        var note = imageNote
        if let url = fileUrl(note.uid), let data = note.image()?.jpegData(compressionQuality: 1) ?? note.image()?.pngData() {
            do {try data.write(to: url)} catch {print("Error ")}
            note = ImageNote(uid: note.uid, imagePath: url.path)
        }
        switch index(of: note) {
        case let index?:
            imageNotes[index] = note
        default:
            imageNotes.append(note)
        }
        save()
    }
    
    public func index(of imageNote: ImageNote) -> Int? {
        return imageNotes.firstIndex {note in note.uid == imageNote.uid}
    }
    
    public func remove(with uid: String) {
        try? FileManager.default.removeItem(at: fileUrl(uid)!)
        imageNotes.removeAll {note in note.uid == uid}
        save()
    }
    
    public func remove(with index: Int) {
        try? FileManager.default.removeItem(at: fileUrl(imageNotes[index].uid)!)
        imageNotes.remove(at: index)
        save()
    }
    
    public func remove(_ note: ImageNote) {
        guard let index = index(of: note) else {
            return
        }
        remove(with: index)
    }
    
    private let fileUrl = {(fileName: String) -> URL? in
        return FileManager.default.urls(for: .documentDirectory,
                                        in: .userDomainMask).first?.appendingPathComponent(fileName)
    }
    
    public func load() {
        guard let file = fileUrl(Str.fileName) else {
            DDLogError("ImageNotes load: File do not accessible.")
            return
        }
        guard let data = try? Data(contentsOf: file) else {
            DDLogError("ImageNotes load: Reading file error.")
            return
        }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: [[String: Any]]] else {
            DDLogError("ImageNotes load: Data deserialization error.")
            return
        }
        json[Str.jsonRoot]?.forEach {item in
            switch ImageNote.parse(json: item) {
            case let note?: imageNotes.append(note)
            default: break
            }
        }
    }
    
    private func save() {
        var items = [[String: Any]]()
        imageNotes.forEach {note in
            items.append(note.json)
        }
        let dict: [String: Any] = [Str.jsonRoot: items]
        
        guard let json = try? JSONSerialization.data(withJSONObject: dict, options: []) else {
            DDLogError("ImageNotes save: Data serialization error.")
            return
        }
        guard let file = fileUrl(Str.fileName), (FileManager.default.fileExists(atPath: file.path) || FileManager.default.createFile(atPath: file.path, contents: nil, attributes: nil)) else {
            DDLogError("ImageNotes save: File do not accessilbe.")
            return
        }
        guard ((try? json.write(to: file)) != nil) else {
            DDLogError("ImageNotes save: Writing file error.")
            return
        }
    }
}
