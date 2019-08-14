import Foundation
import CocoaLumberjack

class SaveImageNoteOperation: AsyncOperation {
    private let note: ImageNote
    private let gallery: FileGallery
    private let saveToDb: SaveImageNoteDBOperation
    private var saveToBackend: SaveImageNotesBackendOperation
    
    private(set) var result: Bool? = false
    
    init(note: ImageNote,
         gallery: FileGallery,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue) {
        self.note = note
        self.gallery = gallery
        
        saveToDb = SaveImageNoteDBOperation(note: note, gallery: gallery)
        saveToBackend = SaveImageNotesBackendOperation(imageNotesProvider: saveToDb)
        
        super.init()
        
        // Порядок выполнения операций
        // SaveImageNotesBackendOperation выполнится после SaveImageNoteDBOperation
        // SaveImageNoteOperation выполнится после SaveImageNotesBackendOperation
        saveToBackend.addDependency(saveToDb)
        addDependency(saveToBackend)
        dbQueue.addOperation(saveToDb)
        backendQueue.addOperation(saveToBackend)
    }
    
    override func main() {
        DDLogInfo("SaveImageNoteOperation execution")
        switch saveToBackend.result! {
        case .success:
            result = true
        case .failure:
            result = false
        }
        finish()
    }
}
