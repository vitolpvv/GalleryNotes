import Foundation

enum NetworkError: Error {
    case unreachable
}

class BaseBackendOperation: AsyncOperation {
    override init() {
        super.init()
    }
}
