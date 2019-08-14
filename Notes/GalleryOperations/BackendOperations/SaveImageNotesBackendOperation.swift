import Foundation
import CocoaLumberjack

class SaveImageNotesBackendOperation: BaseBackendOperation {
    var result: Result<Void, NetworkError>?
    
    init(imageNotesProvider: ImageNotesProvider) {
        super.init()
    }
    
    override func main() {
        DDLogInfo("SaveImageNotesBackendOperation execution")
        result = .failure(.unreachable)
        finish()
    }
}
