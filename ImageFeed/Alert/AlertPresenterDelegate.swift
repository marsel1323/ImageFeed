//
//  AlertPresenterDelegate.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 20.12.2024.
//

import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func viewControllerForAlertPresentation() -> UIViewController
}
