//
//  WebViewViewControllerSpy.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 13.07.2025.
//

import Foundation
@testable import ImageFeed

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {

    var loadRequestCalled: Bool = false
    var presenter: WebViewPresenterProtocol?

    func load(request: URLRequest) {
        loadRequestCalled = true
    }

    func setProgressValue(_ newValue: Float) {}

    func setProgressHidden(_ isHidden: Bool) {}
}
