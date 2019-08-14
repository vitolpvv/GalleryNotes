import UIKit
import CoreData
import CocoaLumberjack

class RemoveNoteDBOperation: BaseDBOperation {    
    private let note: Note
    
    init(note: Note,
         notebook: DBNotebook, context: NSManagedObjectContext) {
        self.note = note
        super.init(notebook: notebook, context: context)
    }
    
    override func main() {
        DDLogInfo("RemoveNoteDBOperation execution")
        notebook.remove(note, on: context)
        finish()
    }
}

// У RemoveNoteDBOperation можно получить список заметок
extension RemoveNoteDBOperation: NotesProvider {
    var notes: [Note] {
        get{
            return notebook.notes
        }
    }
}
