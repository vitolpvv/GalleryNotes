import Foundation
import CocoaLumberjack

class RemoveImageNoteDBOperation: BaseImageDBOperation {
    private let note: ImageNote
    
    init(note: ImageNote,
         gallery: FileGallery) {
        self.note = note
        super.init(gallery: gallery)
    }
    
    override func main() {
        DDLogInfo("RemoveImageNoteDBOperation execution")
        gallery.remove(note)
        finish()
    }
}

// У RemoveImageNoteDBOperation можно получить список заметок
extension RemoveImageNoteDBOperation: ImageNotesProvider {
    var imageNotes: [ImageNote] {
        get{
            return gallery.imageNotes
        }
    }
}
