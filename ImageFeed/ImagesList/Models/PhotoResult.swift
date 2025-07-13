//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 03.06.2025.
//

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String
    let width, height: Int
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult
}
