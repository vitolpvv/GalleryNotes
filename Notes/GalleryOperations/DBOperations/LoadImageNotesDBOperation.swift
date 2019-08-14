import Foundation
import CocoaLumberjack

class LoadImageNotesDBOperation: BaseImageDBOperation {
    
    override func main() {
        DDLogInfo("LoadImageNotesDBOperation execution")
        gallery.load()
        finish()
    }
}
