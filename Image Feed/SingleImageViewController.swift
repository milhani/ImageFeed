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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 8 //1.25
        imageView.image = image
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    @IBAction func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        if let image = imageView.image {
            let zoom = max(scrollView.bounds.size.width / image.size.width,
                              scrollView.bounds.size.height / image.size.height)
            scrollView.setZoomScale(zoom, animated: false)
            scrollView.layoutIfNeeded()
        }
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
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraints()
    }
}
