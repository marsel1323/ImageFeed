//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 26.03.2025.
//

import Foundation

final class OAuth2Service {
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        completion(.success(""))
    }
}
