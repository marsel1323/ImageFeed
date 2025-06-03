//
//  TabBarController.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 28.05.2025.
//

import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        )
        
        let profileViewController = ProfileViewController()
        
        viewControllers = [imagesListViewController, profileViewController]
    }
}
