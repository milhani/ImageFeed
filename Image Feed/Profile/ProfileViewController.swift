import Kingfisher
import UIKit

final class ProfileViewController: UIViewController {
    
    private var avatarImage = UIImageView()
    private var nameLabel = UILabel()
    private var loginNameLabel = UILabel()
    private var descriptionLabel = UILabel()
    private var logoutButton = UIButton()
    
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
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
        
        createAvatarImage()
        createNameLabel()
        createLoginNameLabel()
        createDescriptionLabel()
        creatLogoutButton()
        
        createConstraint()
        
        guard let profile = profileService.profile else { return }
        updateProfileDetails(profile: profile)
        
        if let avatarURL = ProfileImageService.shared.avatarURL,
           let url = URL(string: avatarURL) {
            print(avatarURL)
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
        
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImage)
    }
    
    private func createNameLabel() {
        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: UIFont.Weight.bold)
        nameLabel.textColor = .ypWhite
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
    }
    
    private func createLoginNameLabel() {
        loginNameLabel.text = "@ekaterina_nov"
        loginNameLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.regular)
        loginNameLabel.textColor = .ypGray
        
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
    }
    
    private func createDescriptionLabel() {
        descriptionLabel.text = "Hello, World!"
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.regular)
        descriptionLabel.textColor = .ypWhite
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
    }
    
    private func creatLogoutButton() {
        logoutButton = UIButton.systemButton(
            with: (UIImage(named: "logout_button") ?? UIImage(systemName: "person.crop.circle.fill"))!,
            target: self,
            action: #selector(Self.didTapLogoutButton)
        )
        
        logoutButton.tintColor = .ypRed
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
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
        avatarImage.kf.setImage(with: url,
                                          placeholder: UIImage(systemName: "person.crop.circle.fill"),
                                          options: [.processor(processor),
                                                    .cacheSerializer(FormatIndicatedCacheSerializer.png)]) {result in
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
        for v in view.subviews {
            if let v = v as? UILabel {
                v.removeFromSuperview()
            } else if let v = v as? UIImageView {
                v.image = UIImage(systemName: "person.crop.circle.fill")
                v.tintColor = .ypGray
                v.widthAnchor.constraint(equalToConstant: 70).isActive = true
                v.heightAnchor.constraint(equalToConstant: 70).isActive = true
            }
        }
    }
}
