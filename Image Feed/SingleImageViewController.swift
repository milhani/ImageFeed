import Kingfisher
import ProgressHUD
import UIKit

final class SingleImageViewController: UIViewController {

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageConstraintBottom: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintLeft: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintRight: NSLayoutConstraint!
    
    var image: UIImage! {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    var fullImageUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImage()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 8 //1.25
    }
    
    @IBAction func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        let share = UIActivityViewController(
            activityItems: [image as Any],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let zoom = max(scrollView.bounds.size.width / image.size.width,
                          scrollView.bounds.size.height / image.size.height)
        scrollView.setZoomScale(zoom, animated: false)
        scrollView.layoutIfNeeded()

    }
    
    private func updateConstraints() {
        if let image = imageView.image {
            let viewWidth = scrollView.bounds.size.width
            let viewHeight = scrollView.bounds.size.height
            
            let x = (viewWidth - scrollView.zoomScale * image.size.width) / 2
            let y = (viewHeight - scrollView.zoomScale * image.size.height) / 2
            
            imageConstraintLeft.constant = x
            imageConstraintRight.constant = x
            
            imageConstraintTop.constant = y
            imageConstraintBottom.constant = y
            
            view.layoutIfNeeded()
        }
    }
    
    private func loadImage() {
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: fullImageUrl) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                self.image = imageResult.image
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure(let error):
                print("[loadImage]: \(error.localizedDescription)")
                self.showError()
            }
        }
    }
    
    private func showError() {
        let alertController = UIAlertController(
            title: "Что-то пошло не так",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )
        let cancel = UIAlertAction(
            title: "Не надо",
            style: .default
        )
        let action = UIAlertAction(
            title: "Повторить",
            style: .default
        ) { _ in
            self.loadImage()
        }
        alertController.addAction(action)
        alertController.addAction(cancel)
        present(alertController, animated: true)
    }
}

// MARK: - UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraints()
    }
}
