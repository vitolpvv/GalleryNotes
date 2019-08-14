import UIKit
import CoreData

class BaseDBOperation: AsyncOperation {
    let notebook: DBNotebook
    let context: NSManagedObjectContext
    
    init(notebook: DBNotebook, context: NSManagedObjectContext) {
        self.notebook = notebook
        self.context = context
        super.init()
    }
}
