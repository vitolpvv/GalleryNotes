import Foundation
import CocoaLumberjack

class SaveImageNoteDBOperation: BaseImageDBOperation {    
    private let note: ImageNote
    
    init(note: ImageNote,
         gallery: FileGallery) {
        self.note = note
        super.init(gallery: gallery)
    }
    
    override func main() {
        DDLogInfo("SaveImageNoteDBOperation execution")
        gallery.add(note)
        finish()
    }
}

// У SaveImageNoteDBOperation можно получить список заметок
extension SaveImageNoteDBOperation: ImageNotesProvider {
    var imageNotes: [ImageNote] {
        get{
            return gallery.imageNotes
        }
    }
}
