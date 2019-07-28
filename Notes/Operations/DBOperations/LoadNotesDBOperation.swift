import Foundation
import CocoaLumberjack

class LoadNotesDBOperation: BaseDBOperation {
    
    override func main() {
        DDLogInfo("LoadNotesDBOperation execution")
        notebook.load()
        finish()
    }
}
