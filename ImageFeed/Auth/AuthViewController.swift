//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 26.03.2025.
//

import UIKit

final class AuthViewController: UIViewController {
    weak var delegate: AuthViewControllerDelegate?
    
    private let ShowWebViewSegueIdentifier = "ShowWebView"
    private let oAuth2Service = OAuth2Service.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBackButton()
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowWebViewSegueIdentifier {
            guard let webViewController = segue.destination as? WebViewViewController else {
                assertionFailure("Failed to prepare for \(ShowWebViewSegueIdentifier)")
                return
            }
            webViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        print("Authorization status code: \(code)")
        oAuth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let token):
                print("Token: \(token)")
                
                OAuth2TokenStorage.shared.token = token
                
                self.delegate?.didAuthenticate(self)
            case .failure(let error):
                print("Failed to fetch OAuth token: \(error.localizedDescription)")
            }
        }
        
        vc.dismiss(animated: true)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
        print("Authorization is cancelled")
    }
}
