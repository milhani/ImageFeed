import Kingfisher
import UIKit
import WebKit

final class ProfileViewController: UIViewController {
    
    private var avatarImage = UIImageView()
    private var nameLabel = UILabel()
    private var loginNameLabel = UILabel()
    private var descriptionLabel = UILabel()
    private var logoutButton = UIButton()
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private let profileService = ProfileService.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let imagesListService = ImagesListService.shared
    
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
        addObserver()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addObserver()
    }
    
    deinit {
        removeObserver()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        
        createAvatarImage()
        createNameLabel()
        createLoginNameLabel()
        createDescriptionLabel()
        creatLogoutButton()
        
        [avatarImage,
         nameLabel,
         loginNameLabel,
         descriptionLabel,
         logoutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
             view.addSubview($0)
        }
        
        createConstraint()
        
        guard let profile = profileService.profile else { return }
        updateProfileDetails(profile: profile)
        
        if let avatarURL = ProfileImageService.shared.avatarURL,
           let url = URL(string: avatarURL) {
            updateAvatar(url: url)
        }
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                guard let self = self else { return }
                self.updateAvatar(notification: notification)
            }
        
    }
    
    private func createConstraint() {
        NSLayoutConstraint.activate([
            avatarImage.widthAnchor.constraint(equalToConstant: 70),
            avatarImage.heightAnchor.constraint(equalToConstant: 70),
            avatarImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarImage.bottomAnchor, constant: 8),

            loginNameLabel.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),

            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),

            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImage.centerYAnchor)
        ])
        
    }
    
    private func createAvatarImage() {
        let profileImage = UIImage(named: "avatar")
        avatarImage = UIImageView(image: profileImage)
        avatarImage.layer.masksToBounds = true
        avatarImage.layer.cornerRadius = 35
    }
    
    private func createNameLabel() {
        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: UIFont.Weight.bold)
        nameLabel.textColor = .ypWhite
    }
    
    private func createLoginNameLabel() {
        loginNameLabel.text = "@ekaterina_nov"
        loginNameLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.regular)
        loginNameLabel.textColor = .ypGray
    }
    
    private func createDescriptionLabel() {
        descriptionLabel.text = "Hello, World!"
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.regular)
        descriptionLabel.textColor = .ypWhite
    }
    
    private func creatLogoutButton() {
        logoutButton = UIButton.systemButton(
            with: (UIImage(named: "logout_button") ?? UIImage(systemName: "person.crop.circle.fill"))!,
            target: self,
            action: #selector(Self.didTapLogoutButton)
        )
        logoutButton.tintColor = .ypRed
    }
    
    private func updateProfileDetails(profile: Profile) {
        self.nameLabel.text = profile.name
        self.loginNameLabel.text = profile.username
        self.descriptionLabel.text = profile.bio
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateAvatar(notification:)),
            name: ProfileImageService.didChangeNotification,
            object: nil)
    }
   
   private func removeObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: ProfileImageService.didChangeNotification,
            object: nil)
    }
    
    private func updateAvatar(url: URL) {
        avatarImage.kf.indicatorType = .activity
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        avatarImage.kf.setImage(with: url, options: [.processor(processor)])
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
        for view in view.subviews {
            if let view = view as? UILabel {
                view.removeFromSuperview()
            } else if let view = view as? UIImageView {
                view.image = UIImage(systemName: "person.crop.circle.fill")
                view.tintColor = .ypGray
                view.widthAnchor.constraint(equalToConstant: 70).isActive = true
                view.heightAnchor.constraint(equalToConstant: 70).isActive = true
            }
        }
        
        guard let window = UIApplication.shared.windows.first else { preconditionFailure("Invalid Configuration") }
        window.rootViewController = SplashViewController()
    }
    
    @objc
    private func updateAvatar(notification: Notification) {
        guard
            isViewLoaded,
            let userInfo = notification.userInfo,
            let profileImageURL = userInfo["URL"] as? String,
            let url = URL(string: profileImageURL)
        else { return }
        let processor = RoundCornerImageProcessor(cornerRadius: 35, backgroundColor: .clear)
        avatarImage.kf.indicatorType = .activity
        avatarImage.kf.setImage(
            with: url,
            placeholder: UIImage(systemName: "person.crop.circle.fill"),
            options: [
                .processor(processor),
                .cacheSerializer(FormatIndicatedCacheSerializer.png)
            ]
        ) { result in
            switch result {
                case.success(let value):
                    print(value.image)
                    print(value.cacheType)
                    print(value.source)
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    @objc
    private func didTapLogoutButton() {
        let alertController = UIAlertController(title: "Пока, пока!",
                                                message: "Уверены, что хотите выйти?",
                                                preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Нет",
                                   style: .cancel)
        let action = UIAlertAction(title: "Да", style: .default) { _ in
            self.cleanCookies()
            self.cleanToken()
            self.cleanPhotos()
            self.cleanView()
        }
        alertController.addAction(action)
        alertController.addAction(cancel)
        present(alertController, animated: true)
    }
}
