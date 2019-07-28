import Foundation
import CocoaLumberjack

class SaveNoteOperation: AsyncOperation {
    private let note: Note
    private let notebook: FileNotebook
    private let saveToDb: SaveNoteDBOperation
    private var saveToBackend: SaveNotesBackendOperation
    
    private(set) var result: Bool? = false
    
    init(note: Note,
         notebook: FileNotebook,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue) {
        self.note = note
        self.notebook = notebook
        
        saveToDb = SaveNoteDBOperation(note: note, notebook: notebook)
        saveToBackend = SaveNotesBackendOperation(notesProvider: saveToDb)
        
        super.init()
        
        // Порядок выполнения операций
        // SaveNotesBackendOperation выполнится после SaveNoteDBOperation
        // SaveNoteOperation выполнится после SaveNotesBackendOperation
        saveToBackend.addDependency(saveToDb)
        addDependency(saveToBackend)
        dbQueue.addOperation(saveToDb)
        backendQueue.addOperation(saveToBackend)
    }
    
    override func main() {
        DDLogInfo("SaveNoteOperation execution")
        switch saveToBackend.result! {
        case .success:
            result = true
        case .failure:
            result = false
        }
        finish()
    }
}
