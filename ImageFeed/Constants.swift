//
//  Constants.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 26.03.2025.
//

import Foundation

enum Constants {
    static let accessKey = "AS5LY_iElTTRdyqE60NPiuAJ2J3TxR_BoclJqyx94Kw"
    static let secretKey = "-4Wvi5iBWbbA4EBTIlrwhWvUFyJAuliQnBsSGpOr0eg"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let unsplashOauthTokenURLString = "https://unsplash.com/oauth/token"
}
