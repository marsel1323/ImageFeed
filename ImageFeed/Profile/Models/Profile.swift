//
//  Profile.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 28.05.2025.
//

public struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String
    
    public init(username: String, name: String, loginName: String, bio: String) {
        self.username = username
        self.name = name
        self.loginName = loginName
        self.bio = bio
    }
    
    init(from profileResult: ProfileResult) {
        self.username = profileResult.username
        self.name = "\(profileResult.firstName ?? "") \(profileResult.lastName ?? "")"
        self.loginName = "@\(profileResult.username)"
        self.bio = profileResult.bio ?? ""
    }
}
