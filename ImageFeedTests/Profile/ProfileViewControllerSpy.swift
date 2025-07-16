//
//  ProfileViewControllerSpy.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 16.07.2025.
//

import Foundation
@testable import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var profile: Profile?
    var profileImageURL: URL?
    var showCalled = false
    var switchToSplashViewControllerCalled = false
    
    var presenter: ProfilePresenterProtocol?
    
    func setProfileDetails(profile: Profile) {
        self.profile = profile
    }
    
    func setAvatarImage(with url: URL) {
        profileImageURL = url
    }
    
    func showAlert(_ alertModel: AlertModel) {
        showCalled = true
    }
    
    func switchToSplashViewController() {}
}
