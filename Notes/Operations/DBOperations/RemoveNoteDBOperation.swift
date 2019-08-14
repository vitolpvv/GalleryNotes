import Foundation
import CocoaLumberjack

class RemoveNoteDBOperation: BaseDBOperation {    
    private let note: Note
    
    init(note: Note,
         notebook: FileNotebook) {
        self.note = note
        super.init(notebook: notebook)
    }
    
    override func main() {
        DDLogInfo("RemoveNoteDBOperation execution")
        notebook.remove(note)
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
