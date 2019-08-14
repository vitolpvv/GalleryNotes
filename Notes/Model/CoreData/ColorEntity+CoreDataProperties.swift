//
//  ColorEntity+CoreDataProperties.swift
//  Notes
//
//  Created by VitalyP on 14/08/2019.
//  Copyright © 2019 vitalyp. All rights reserved.
//
//

import Foundation
import CoreData


extension ColorEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ColorEntity> {
        return NSFetchRequest<ColorEntity>(entityName: "ColorEntity")
    }

    @NSManaged public var red: Double
    @NSManaged public var green: Double
    @NSManaged public var blue: Double
    @NSManaged public var alpha: Double
    @NSManaged public var note: NoteEntity?

}
