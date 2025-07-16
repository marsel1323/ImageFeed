//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 15.07.2025.
//

import Foundation

public protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func updateAvatar()
    func userDidLogout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    func viewDidLoad() {
        guard let profile = ProfileService.shared.profile else { return }
        setupNotificationObserver()
        view?.setProfileDetails(profile: profile)
        updateAvatar()
    }
    
    private func setupNotificationObserver() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
    }
    
    func updateAvatar() {
        guard
            let avatarURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: avatarURL)
        else { return }
        
        view?.setAvatarImage(with: url)
    }
    
    func userDidLogout() {
        let alertModel = AlertModel(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            buttons: [
                (
                    title: "Да",
                    completion: { [weak self] in
                        guard let self else { return }
                        ProfileLogoutService.shared.logout()
                        view?.switchToSplashViewController()
                    }),
                (
                    title: "Нет",
                    completion: nil
                )
            ]
        )
        view?.showAlert(alertModel)
    }
}
