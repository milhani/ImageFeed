import Foundation
import WebKit

protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func cleanUserData()
    func viewDidLoad()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let imagesListService = ImagesListService.shared
    
    func viewDidLoad() {
        guard let profile = profileService.profile else { return }
        view?.updateProfileDetails(profile: profile)
        
        if let urlString = profileImageService.avatarURL {
            if let url = URL(string: urlString) {
              view?.updateAvatar(url: url)
            }
        }
    }
    
    func cleanUserData() {
        cleanToken()
        cleanCookies()
        cleanView()
        cleanPhotos()
        goToSplashScreen()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func cleanToken() {
        oauth2TokenStorage.cleanToken()
    }
    
    private func cleanPhotos() {
        imagesListService.cleanPhotos()
    }
    
    private func cleanView() {
        view?.cleanView()
    }
    
    private func goToSplashScreen() {
        guard let window = UIApplication.shared.windows.first else { preconditionFailure("Invalid Configuration") }
        window.rootViewController = SplashViewController()
    }
}
