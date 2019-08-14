import Foundation
import CocoaLumberjack

class RemoveImageNoteOperation: AsyncOperation {
    private let note: ImageNote
    private let gallery: FileGallery
    private let removeFromDb: RemoveImageNoteDBOperation
    private var saveToBackend: SaveImageNotesBackendOperation
    
    private(set) var result: Bool? = false
    
    init(note: ImageNote,
         gallery: FileGallery,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue) {
        self.note = note
        self.gallery = gallery
        
        removeFromDb = RemoveImageNoteDBOperation(note: note, gallery: gallery)
        saveToBackend = SaveImageNotesBackendOperation(imageNotesProvider: removeFromDb)

        super.init()
        
        // Порядок выполнения операций
        // SaveImageNotesBackendOperation выполнится после RemoveImageNoteDBOperation
        // RemoveImageNoteOperation выполнится после SaveImageNotesBackendOperation
        saveToBackend.addDependency(removeFromDb)
        addDependency(saveToBackend)
        dbQueue.addOperation(removeFromDb)
        backendQueue.addOperation(saveToBackend)
    }
    
    override func main() {
        DDLogInfo("RemoveImageNoteOperation execution")
        switch saveToBackend.result! {
        case .success:
            result = true
        case .failure:
            result = false
        }
        finish()
    }
}
