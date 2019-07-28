import Foundation
import CocoaLumberjack

class RemoveNoteOperation: AsyncOperation {
    private let note: Note
    private let notebook: FileNotebook
    private let removeFromDb: RemoveNoteDBOperation
    private var saveToBackend: SaveNotesBackendOperation
    
    private(set) var result: Bool? = false
    
    init(note: Note,
         notebook: FileNotebook,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue) {
        self.note = note
        self.notebook = notebook
        
        removeFromDb = RemoveNoteDBOperation(note: note, notebook: notebook)
        saveToBackend = SaveNotesBackendOperation(notesProvider: removeFromDb)

        super.init()
        
        // Порядок выполнения операций
        // SaveNotesBackendOperation выполнится после RemoveNoteDBOperation
        // RemoveNoteOperation выполнится после SaveNotesBackendOperation
        saveToBackend.addDependency(removeFromDb)
        addDependency(saveToBackend)
        dbQueue.addOperation(removeFromDb)
        backendQueue.addOperation(saveToBackend)
    }
    
    override func main() {
        DDLogInfo("RemoveNoteOperation execution")
        switch saveToBackend.result! {
        case .success:
            result = true
        case .failure:
            result = false
        }
        finish()
    }
}
