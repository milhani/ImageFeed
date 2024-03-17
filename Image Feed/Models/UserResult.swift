import Foundation

struct UserResult: Codable {
    var profile_image: ImageURL?
}

struct ImageURL: Codable {
    var small: String?
    var medium: String?
    var large: String?
}
