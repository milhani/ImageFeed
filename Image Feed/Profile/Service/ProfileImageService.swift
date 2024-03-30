import Foundation

final class ProfileImageService {
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()
    
    private let urlSession = URLSession.shared
    private (set) var avatarURL: String?
    private var task: URLSessionTask?
    
    private init() {}
    
    func fetchProfileImageURL(username: String, token: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://api.unsplash.com"),
              var request = URLRequest.makeHTTPRequest(path: "/users/\(username)", httpMethod: "GET", baseURL: url)
        else { return }
    
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        assert(Thread.isMainThread)
        task?.cancel()

        task = urlSession.objectTask(for: request) { [weak self] (response: Result<UserResult, Error>)  in
            guard let self else { return }
            self.task = nil
            switch response {
            case .success(let profileResult):
                guard let mediumImage = profileResult.profile_image?.medium else { return }
                self.avatarURL = mediumImage
                completion(.success(mediumImage))
                NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": self.avatarURL as Any])
            case .failure(let error):
                print("[ProfileImageService]: \(error.localizedDescription) \(request)")
                completion(.failure(error))
            }
        }
    }
}
