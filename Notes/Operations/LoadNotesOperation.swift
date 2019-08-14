import UIKit
import CoreData
import CocoaLumberjack

class LoadNotesOperation: AsyncOperation {
    private let notebook: DBNotebook
    private let loadFromDb: LoadNotesDBOperation
    private var loadFromBackend: LoadNotesBackendOperation
    
    private(set) var result: Bool? = false
    
    init(notebook: DBNotebook,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue, context: NSManagedObjectContext) {
        self.notebook = notebook
        
        loadFromDb = LoadNotesDBOperation(notebook: notebook, context: context)
        loadFromBackend = LoadNotesBackendOperation()
        super.init()
        
        // После загрузки заметок из БД.
        loadFromDb.completionBlock = {
            // Если заметки с сервера были загружены, актуализируем заметки в БД.
            switch self.loadFromBackend.result! {
            case .success(let notes):
                if notebook.notes != notes {
                    while notebook.notes.count > 0 {
                        notebook.remove(at: 0, on: context)
                    }
                    notes.forEach { note in
                        notebook.add(note, on: context)
                    }
                }
            default: return
            }
        }
        
        // Порядок выполнения операций
        // LoadNotesDBOperation выполнится после LoadNotesBackendOperation
        // LoadNotesOperation выполнится после LoadNotesDBOperation
        loadFromDb.addDependency(loadFromBackend)
        addDependency(loadFromDb)
        backendQueue.addOperation(loadFromBackend)
        dbQueue.addOperation(loadFromDb)
    }
    
    override func main() {
        DDLogInfo("LoadNotesOperation execution")
        switch loadFromBackend.result! {
        case .success:
            result = true
        case .failure:
            result = false
        }
        finish()
    }
}
