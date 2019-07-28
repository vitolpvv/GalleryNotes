//
//  NotesProvider.swift
//  Notes
//
//  Created by VitalyP on 28/07/2019.
//  Copyright © 2019 vitalyp. All rights reserved.
//

import Foundation

// Протокол позволяет стать источником заметок.
protocol ImageNotesProvider {
    var imageNotes: [ImageNote] {get}
}
