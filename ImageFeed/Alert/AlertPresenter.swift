//
//  AlertPresenter.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 20.12.2024.
//

import UIKit

final class AlertPresenter {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController? = nil) {
        self.viewController = viewController
    }
    
    func showAlert(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert
        )
        for button in alertModel.buttons {
            let action = UIAlertAction(title: button.title, style: .default) { _ in
                button.completion?()
            }
            alert.addAction(action)
        }
        
        alert.preferredAction = alert.actions.last
        
        viewController?.present(alert, animated: true)
    }
}
