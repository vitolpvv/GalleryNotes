//
//  DBNotebook.swift
//  Notes
//
//  Created by VitalyP on 14/08/2019.
//  Copyright © 2019 vitalyp. All rights reserved.
//

import UIKit
import CoreData
import CocoaLumberjack

class DBNotebook {
    
    private let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
    
    public private(set) var notes = [Note]()
    
    public func add(_ note: Note, on context: NSManagedObjectContext) {
        switch indexOf(note) {
        case let index?:
            notes[index] = note
            if let noteEntry = fetchBy(uid: note.uid, on: context) { fillEntity(noteEntry, by: note) }
        case .none:
            createEntity(for: note, on: context)
            notes.append(note)
        }
        save(on: context)
    }
    
    public func remove(_ note: Note, on context: NSManagedObjectContext) {
        guard let index = indexOf(note) else {
            return
        }
        if let noteEntry = fetchBy(uid: note.uid, on: context) {
            context.delete(noteEntry)
            notes.remove(at: index)
            save(on: context)
        }
    }
    
    public func remove(at index: Int, on context: NSManagedObjectContext) {
        guard notes.count > index, index >= 0 else {
            return
        }
        if let noteEntry = fetchBy(uid: notes[index].uid, on: context) {
            context.delete(noteEntry)
            notes.remove(at: index)
            save(on: context)
        }
    }
    
    public func indexOf(_ note: Note) -> Int? {
        return notes.firstIndex { $0.uid == note.uid }
    }
    
    private func save(on context: NSManagedObjectContext) {
        if context.hasChanges {
            context.performAndWait {                
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    DDLogError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }
    
    public func load(on context: NSManagedObjectContext) {
        guard let noteEntities = try? context.fetch(request) else {
            return
        }
        notes = noteEntities.map { entity in
            return Note(uid: entity.uid!,
                        title: entity.title!,
                        content: entity.content!,
                        color: UIColor(red: CGFloat(entity.color!.red),
                                       green: CGFloat(entity.color!.green),
                                       blue: CGFloat(entity.color!.blue),
                                       alpha: CGFloat(entity.color!.alpha)),
                        importance: Note.Importance(rawValue: entity.importance!)!,
                        destroyDate: entity.destroyDate)
        }
    }
    
    private func fetchBy(uid: String, on context: NSManagedObjectContext) -> NoteEntity? {
        let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "uid = %@", uid)
        return try? context.fetch(request).first
    }
    
    private func createEntity(for note: Note, on context: NSManagedObjectContext) {
        let entity = NoteEntity(context: context)
        let colorEntity = ColorEntity(context: context)
        entity.color = colorEntity
        fillEntity(entity, by: note)
    }
    
    private func fillEntity(_ entity: NoteEntity, by note: Note) {
        entity.uid = note.uid
        entity.title = note.title
        entity.content = note.content
        entity.destroyDate = note.destroyDate
        entity.importance = note.importance.rawValue
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        note.color.getRed(&r, green: &g, blue: &b, alpha: &a)
        entity.color!.red = Double(r)
        entity.color!.green = Double(g)
        entity.color!.blue = Double(b)
        entity.color!.alpha = Double(a)
    }
}
