//
//  ImagesListTests.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 15.07.2025.
//

import XCTest
@testable import ImageFeed

final class ImagesListTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // given
        let controller = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        
        controller.presenter = presenter
        presenter.view = controller
        
        // when
        _ = controller.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testWillDisplayCell() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        controller.loadViewIfNeeded()
        
        let presenter = ImagesListPresenterSpy()
        
        controller.presenter = presenter
        presenter.view = controller
        
        // when
        let numberOfRows = controller.tableView.dataSource?.tableView(
            controller.tableView,
            numberOfRowsInSection: 0
        )        
        
        // then
        XCTAssertEqual(numberOfRows, 10)
    }
}
