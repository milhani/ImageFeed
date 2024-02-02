import UIKit

final class ProfileViewController: UIViewController {
    
    @IBOutlet private var avatarImage: UIImageView!
    
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var loginNameLabel: UILabel!
    @IBOutlet private var nameLabel: UILabel!
    
    @IBOutlet private var logoutButton: UIButton!
    
    @IBAction private func didTapLogoutButton() {
    }
}
