import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage! {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet weak var imageConstraintBottom: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintLeft: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintRight: NSLayoutConstraint!
    
    @IBAction func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 8 //1.25
        imageView.image = image
        rescaleAndCenterImageInScrollView(image: image)
        print("didload")
    }
    @IBAction func didTapShareButton(_ sender: Any) {
        let share = UIActivityViewController(
            activityItems: [image ?? 1],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        if let image = imageView.image {
            let zoom = max(scrollView.bounds.size.width / image.size.width,
                              scrollView.bounds.size.height / image.size.height)
            print(zoom)
            scrollView.setZoomScale(zoom, animated: false)
            scrollView.layoutIfNeeded()
        }
    }
    
    func updateConstraints() {
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
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraints()
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
