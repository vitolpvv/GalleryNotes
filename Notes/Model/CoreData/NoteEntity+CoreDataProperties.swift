//
//  NoteEntity+CoreDataProperties.swift
//  Notes
//
//  Created by VitalyP on 14/08/2019.
//  Copyright © 2019 vitalyp. All rights reserved.
//
//

import Foundation
import CoreData


extension NoteEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteEntity> {
        return NSFetchRequest<NoteEntity>(entityName: "NoteEntity")
    }

    @NSManaged public var uid: String
    @NSManaged public var title: String
    @NSManaged public var content: String
    @NSManaged public var importance: String
    @NSManaged public var destroyDate: Date?
    @NSManaged public var color: ColorEntity

}
