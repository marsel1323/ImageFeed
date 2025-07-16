//
//  ProfilePresenterSpy.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 16.07.2025.
//

@testable import ImageFeed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var viewDidLoadCalled = false
    
    var view: ProfileViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func updateAvatar() {}
    
    func userDidLogout() {}
}
