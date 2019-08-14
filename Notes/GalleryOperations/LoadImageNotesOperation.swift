import Foundation
import CocoaLumberjack

class LoadImageNotesOperation: AsyncOperation {
    private let gallery: FileGallery
    private let loadFromDb: LoadImageNotesDBOperation
    private var loadFromBackend: LoadImageNotesBackendOperation
    
    private(set) var result: Bool? = false
    
    init(gallery: FileGallery,
         backendQueue: OperationQueue,
         dbQueue: OperationQueue) {
        self.gallery = gallery
        
        loadFromDb = LoadImageNotesDBOperation(gallery: gallery)
        loadFromBackend = LoadImageNotesBackendOperation()
        super.init()
        
        // После загрузки заметок из БД.
        loadFromDb.completionBlock = {
            // Если заметки с сервера были загружены, актуализируем заметки в БД.
            switch self.loadFromBackend.result! {
            case .success(let notes):
                if gallery.imageNotes != notes {
                    while gallery.imageNotes.count > 0 {
                        gallery.remove(with: 0)
                    }
                    notes.forEach { note in
                        gallery.add(note)
                    }
                }
            default: return
            }
        }
        
        // Порядок выполнения операций
        // LoadImageNotesDBOperation выполнится после LoadImageNotesBackendOperation
        // LoadImageNotesOperation выполнится после LoadImageNotesDBOperation
        loadFromDb.addDependency(loadFromBackend)
        addDependency(loadFromDb)
        backendQueue.addOperation(loadFromBackend)
        dbQueue.addOperation(loadFromDb)
    }
    
    override func main() {
        DDLogInfo("LoadImageNotesOperation execution")
        switch loadFromBackend.result! {
        case .success:
            result = true
        case .failure:
            result = false
        }
        finish()
    }
}
