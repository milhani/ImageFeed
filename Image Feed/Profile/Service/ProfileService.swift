import Foundation

final class ProfileService { 
    static let shared = ProfileService()
    private(set) var profile: Profile?
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    
    private init() {}
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let url = URL(string: "https://api.unsplash.com"),
              var request = URLRequest.makeHTTPRequest(path: "/me", httpMethod: "GET", baseURL: url)
        else { return }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        assert(Thread.isMainThread)
        task?.cancel()
        
        task = urlSession.objectTask(for: request) { [weak self] (response: Result<ProfileResult, Error>)  in
            guard let self else { return }
            self.task = nil
            switch response {
            case .success(let profileResult):
                let profile = Profile(
                    username: profileResult.username,
                    name: "\(profileResult.firstName) \(profileResult.lastName ?? "")",
                    loginName: "@\(profileResult.username)",
                    bio: profileResult.bio ?? "No biography"
                )
                self.profile = profile
                completion(.success((profile)))
            case .failure(let error):
                print("[ProfileService]: \(error.localizedDescription) \(request)")
                completion(.failure(error))
            }
        }
    }
}
