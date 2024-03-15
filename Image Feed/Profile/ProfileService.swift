import Foundation

final class ProfileService { 
    static let shared = ProfileService()
    
    private(set) var profile: Profile?
    
    private init() {} 
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {}
}
