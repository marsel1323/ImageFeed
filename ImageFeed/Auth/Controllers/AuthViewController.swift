//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 26.03.2025.
//

import UIKit

final class AuthViewController: UIViewController {
    weak var delegate: AuthViewControllerDelegate?
    
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let oAuth2Service = OAuth2Service.shared
    
    private weak var viewController: UIViewController?
    
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
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper)
            webViewViewController.presenter = webViewPresenter
            webViewPresenter.view = webViewViewController
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        
        fetchOAuthToken(code) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            
            switch result {
            case .success(let token):
                OAuth2TokenStorage().token = token
                self.delegate?.didAuthenticate(self)
            case .failure(let error):
                let alert = UIAlertController(
                    title: "Что-то пошло не так(",
                    message: "Не удалось войти в систему",
                    preferredStyle: .alert
                )
                
                let action = UIAlertAction(title: "Ok", style: .default) { _ in }
                alert.addAction(action)
                
                viewController?.present(alert, animated: true)
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}

extension AuthViewController {
    private func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        oAuth2Service.fetchOAuthToken(code) { result in
            completion(result)
        }
    }
}
