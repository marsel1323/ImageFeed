//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 23.02.2025.
//

import UIKit

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func setProfileDetails(profile: Profile)
    func setAvatarImage(with url: URL)
    func showAlert(_ alertModel: AlertModel)
    func switchToSplashViewController()
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    
    // MARK: - UI Elements
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "userpick")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
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
        button.accessibilityIdentifier = "logout"
        button.setImage(UIImage(named: "logout_button"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        return button
    }()
    
    var presenter: ProfilePresenterProtocol?
    private lazy var alertPresenter = AlertPresenter(viewController: self)
    private let splashViewControllerIdentifier = "SplashViewController"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        presenter?.viewDidLoad()
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
        presenter?.userDidLogout()
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
    
    func setAvatarImage(with url: URL) {
        avatarImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "userpick")
        )
    }
    
    func setProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
    func showAlert(_ alertModel: AlertModel) {
        alertPresenter.showAlert(alertModel: alertModel)
    }
}
