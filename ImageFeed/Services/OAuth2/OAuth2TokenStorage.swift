//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 26.03.2025.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let storage: KeychainWrapper = .standard
    private let tokenKey = "BearerToken"
        
    var token: String? {
        get {
            return storage.string(forKey: tokenKey)
        }
        set {
            if let newValue {
                storage.set(newValue, forKey: tokenKey)
            } else {
                storage.removeObject(forKey: tokenKey)
            }
        }
    }
    
    func resetToken() {
        storage.removeObject(forKey: tokenKey)
    }
}
