import UIKit
import CoreData
import CocoaLumberjack

class SaveNoteDBOperation: BaseDBOperation {    
    private let note: Note
    
    init(note: Note,
         notebook: DBNotebook, context: NSManagedObjectContext) {
        self.note = note
        super.init(notebook: notebook, context: context)
    }
    
    override func main() {
        DDLogInfo("SaveNoteDBOperation execution")
        notebook.add(note, on: context)
        finish()
    }
}

// У SaveNoteDBOperation можно получить список заметок
extension SaveNoteDBOperation: NotesProvider {
    var notes: [Note] {
        get{
            return notebook.notes
        }
    }
}
