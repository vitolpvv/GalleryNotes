import Foundation

enum NetworkError: Error {
    case unreachable
}

class BaseBackendOperation: AsyncOperation {
    let baseUrlStr = "https://api.github.com/gists"
    let gistDescription = "Vital P Notebook App"
    let fileName = "ios-course-notes-db"
    
    override init() {
        super.init()
    }
}
