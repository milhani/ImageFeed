import Foundation

struct PhotoResult: Codable {
    var id: String
    var width: Int
    var height: Int
    var createdAt: String?
    var description: String?
    var urls: UrlsResult
    var likes: Int
    var likedByUser: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case width = "width"
        case height = "height"
        case createdAt = "created_at"
        case description = "description"
        case urls = "urls"
        case likes = "likes"
        case likedByUser = "liked_by_user"
    }
}

struct PhotoLiked: Codable {
    var photo: PhotoResult
}
