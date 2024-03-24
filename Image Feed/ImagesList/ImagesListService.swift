import Foundation

final class ImagesListService {
    private (set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    
    //let nextPage = (lastLoadedPage?.number ?? 0) + 1
    
    // ...
    
    func fetchPhotosNextPage() {
        let nextPage = (lastLoadedPage?.number ?? 0) + 1
    }
}
