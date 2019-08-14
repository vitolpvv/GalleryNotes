import Foundation
import CocoaLumberjack

class SaveNoteDBOperation: BaseDBOperation {    
    private let note: Note
    
    init(note: Note,
         notebook: FileNotebook) {
        self.note = note
        super.init(notebook: notebook)
    }
    
    override func main() {
        DDLogInfo("SaveNoteDBOperation execution")
        notebook.add(note)
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
