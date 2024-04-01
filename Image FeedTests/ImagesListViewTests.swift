@testable import Image_Feed
import Image_Feed
import XCTest

final class ImagesListViewTests: XCTestCase {

    func testViewControllerCallsViewDidLoad() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.fetchPhotosCalled)
    }
}


final class ImagesListViewPresenterSpy: ImagesListViewPresenterProtocol {
    var fetchPhotosCalled: Bool = false
    var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    
    func fetchPhotos() { 
        fetchPhotosCalled = true
    }
    
    func updateTable() { }
}
