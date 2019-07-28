import Foundation
import CocoaLumberjack

class LoadImageNotesBackendOperation: BaseBackendOperation {
    var result: Result<[ImageNote], NetworkError>?
    
    override func main() {
        DDLogInfo("LoadImageNotesBackendOperations execution")
        result = .failure(.unreachable)
        finish()
    }
}
