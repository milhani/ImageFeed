import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let keychainWrapper = KeychainWrapper.standard
    
    var token: String? {
        get {
            keychainWrapper.string(forKey: "token")
        }
        set {
            guard let newValue = newValue else { return }
            let isSuccess = keychainWrapper.set(newValue, forKey: "token")
            guard isSuccess else {
                fatalError("Ошибка сохранения токена")
            }
        }
    }
    
    func cleanToken() {
        keychainWrapper.removeObject(forKey: "token")
    }
}
