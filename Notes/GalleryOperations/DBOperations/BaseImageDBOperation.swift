import Foundation

class BaseImageDBOperation: AsyncOperation {
    let gallery: FileGallery
    
    init(gallery: FileGallery) {
        self.gallery = gallery
        super.init()
    }
}
