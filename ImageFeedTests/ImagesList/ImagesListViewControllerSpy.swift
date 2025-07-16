//
//  ImagesListViewControllerSpy.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 15.07.2025.
//

@testable import ImageFeed

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    
    func updateTableViewAnimated(from: Int, to: Int) {}
    
    func showSomethingWentWrongError(_ handler: (() -> Void)?) {}
}
