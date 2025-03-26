//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 26.03.2025.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken, tokenType, scope: String
    let createdAt: Int
}
