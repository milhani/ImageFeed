import Foundation

final class ImagesListService {
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private var dateFormat = ISO8601DateFormatter()
    
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let urlSession = URLSession.shared
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    static let shared = ImagesListService()
    
    func fetchPhotosNextPage() {
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let url = URL(string: "https://api.unsplash.com"),
              var request = URLRequest.makeHTTPRequest(path: "/photos?page=\(nextPage)", httpMethod: "GET",
                                                       baseURL: url)
        else { return }
        
        if let token = oauth2TokenStorage.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        assert(Thread.isMainThread)
        
        task = urlSession.objectTask(for: request) { [weak self] (response: Result<[PhotoResult], Error>)  in
            guard let self else { return }
            self.task = nil
            switch response {
            case .success(let body):
                DispatchQueue.main.async {
                    for photo in body {
                        let new = Photo(
                            id: photo.id,
                            size: CGSize(width: photo.width, height: photo.height),
                            createdAt: self.dateFormat.date(from: photo.createdAt ?? ""),
                            welcomeDescription: photo.description ?? "",
                            thumbImageURL: photo.urls.small,
                            largeImageURL: photo.urls.full,
                            isLiked: photo.likedByUser)
                        self.photos.append(new)
                    }
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                }
                self.lastLoadedPage = nextPage
            case .failure(let error):
                print("[ImagesListService]: \(error.localizedDescription) \(request)")
            }
        }
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<PhotoLiked, Error>) -> Void) {
        var method = "POST"
        if isLike { method = "DELETE" }
        guard let url = URL(string: "https://api.unsplash.com"),
              var request = URLRequest.makeHTTPRequest(path: "/photos/\(photoId)/like", httpMethod: method,
                                                       baseURL: url)
        else { return }
        
        if let token = oauth2TokenStorage.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        //assert(Thread.isMainThread)
        
        task = urlSession.objectTask(for: request) { [weak self] (response: Result<PhotoLiked, Error>)  in
            guard let self else { return }
            self.task = nil
            switch response {
            case .success(let body):
                DispatchQueue.main.async {
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let photo = self.photos[index]
                        let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: body.photo.likedByUser
                        )
                        self.photos[index] = newPhoto
                    }
                }
                completion(.success(body))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
