//
//  UserResult.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 28.05.2025.
//

struct UserResult: Codable {
    let profileImage: ProfileImage
}

struct ProfileImage: Codable {
    let small: String
}
