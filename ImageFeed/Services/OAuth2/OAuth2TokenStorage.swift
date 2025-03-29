//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 26.03.2025.
//

import Foundation

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private let storage: UserDefaults = .standard
    private let tokenKey = "BearerToken"
    
    private init () {}
    
    var token: String? {
        get {
            return storage.string(forKey: tokenKey)
        }
        set {
            storage.set(newValue, forKey: tokenKey)
        }
    }
}
