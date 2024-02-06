import UIKit

final class ProfileViewController: UIViewController {
    
    private var avatarImage: UIImageView!
    private var nameLabel: UILabel!
    private var loginNameLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.avatarImage = createAvatarImage()
        self.nameLabel = createNameLabel()
        self.loginNameLabel = createLoginNameLabel()
        self.descriptionLabel = createDescriptionLabel()
        self.logoutButton = creatLogoutButton()
        createConstraint()
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
    
    private func createAvatarImage() -> UIImageView {
        let profileImage = UIImage(named: "avatar")
        let avatarImage = UIImageView(image: profileImage)
        avatarImage.layer.masksToBounds = true
        avatarImage.layer.cornerRadius = 35
        
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImage)
        
        return avatarImage
    }
    
    private func createNameLabel() -> UILabel {
        let nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: UIFont.Weight.bold)
        nameLabel.textColor = UIColor(named: "YP White")
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        return nameLabel
    }
    
    private func createLoginNameLabel() -> UILabel {
        let loginNameLabel = UILabel()
        loginNameLabel.text = "@ekaterina_nov"
        
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        loginNameLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.regular)
        loginNameLabel.textColor = UIColor(named: "YP Gray")
        
        return loginNameLabel
    }
    
    private func createDescriptionLabel() -> UILabel {
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Hello, World!"
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.regular)
        descriptionLabel.textColor = UIColor(named: "YP White")
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        return descriptionLabel
    }
    
    private func creatLogoutButton() -> UIButton {
        let logoutButton = UIButton.systemButton(
            with: (UIImage(named: "logout_button") ?? UIImage(systemName: "person.crop.circle.fill"))!,
            target: self,
            action: #selector(Self.didTapLogoutButton)
        )
        
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        logoutButton.tintColor = .red
        
        return logoutButton
    }
    
    @objc
    private func didTapLogoutButton() {
        for v in view.subviews {
            if let v = v as? UILabel {
                v.removeFromSuperview()
            } else if let v = v as? UIImageView {
                v.image = UIImage(systemName: "person.crop.circle.fill")
                v.tintColor = .gray
                v.widthAnchor.constraint(equalToConstant: 70).isActive = true
                v.heightAnchor.constraint(equalToConstant: 70).isActive = true
            }
        }
    }
}
