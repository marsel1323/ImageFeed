//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 23.02.2025.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "userpick")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35 // 70/2
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        label.textColor = .ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loginNameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "logout_button"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        return button
    }()
    
    private var profileImageServiceObserver: NSObjectProtocol?
    private lazy var alertPresenter = AlertPresenter(viewController: self)
    private let splashViewControllerIdentifier = "SplashViewController"
    private var isLoading = true
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNotificationObserver()
        
        guard let profile = ProfileService.shared.profile else { return }
        
        updateProfileDetails(profile)
        updateAvatar()
        setupUI()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .ypBlack
        
        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
        
        avatarImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        
        nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8).isActive = true
        
        logoutButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor).isActive = true
        
        loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor).isActive = true
        loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        
        descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8).isActive = true
    }
    
    // MARK: - Actions
    
    @objc private func didTapLogoutButton() {
        let alertModel = AlertModel(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            buttons: [
                (
                    title: "Да",
                    completion: { [weak self] in
                        guard let self else { return }
                        ProfileLogoutService.shared.logout()
                        self.switchToSplashViewController()
                    }),
                (
                    title: "Нет",
                    completion: nil
                )
            ]
        )
        alertPresenter.showAlert(alertModel: alertModel)
    }
    
    func switchToSplashViewController() {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        guard let window = windowScene?.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let splashViewController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: splashViewControllerIdentifier)
        
        window.rootViewController = splashViewController
    }
    
    private func updateAvatar() {
        guard
            let avatarURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: avatarURL)
        else { return }
        
        avatarImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "userpick")
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let imageResult):
                self.isLoading = false
                // self.updateViewForProfilePhotoLoad(imageResult.image)
            case .failure:
                break
            }
        }
    }
    
    private func updateProfileDetails(_ profile: Profile) {
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
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
}
