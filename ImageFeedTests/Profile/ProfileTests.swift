//
//  ProfileTests.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 16.07.2025.
//

import XCTest
@testable import ImageFeed

final class ProfileTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsShow() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        presenter.userDidLogout()
        
        // then
        XCTAssertTrue(viewController.showCalled)
    }
    
    func testSetProfileDetailsPassesCorrectData() {
        // given
        let viewController = ProfileViewControllerSpy()
        let profile = Profile(
            username: "marsel132313",
            name: "Marsel Marso",
            loginName: "@marsel132313",
            bio: ""
        )
        
        // when
        viewController.setProfileDetails(profile: profile)
        
        // then
        XCTAssertEqual(viewController.profile?.username, profile.username)
        XCTAssertEqual(viewController.profile?.name, profile.name)
        XCTAssertEqual(viewController.profile?.loginName, profile.loginName)
        XCTAssertEqual(viewController.profile?.bio, profile.bio)
    }
    
    func testSetProfileImagePassesCorrectURL() {
        // given
        let viewController = ProfileViewControllerSpy()
        let url = URL(string: "https://example.com/profile.jpg")!
        
        // when
        viewController.setAvatarImage(with: url)
        
        // yhen
        XCTAssertEqual(viewController.profileImageURL, url)
    }
    
}

