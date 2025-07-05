//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 03.06.2025.
//

import Foundation

final class ImagesListService {
    
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    static let didFailNotification = Notification.Name(rawValue: "ImagesListServiceDidFail")
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    
    private init() {}
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        guard task == nil else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let request = makePhotosNextPageURLRequest(nextPage) else {
            // assertionFailure(NetworkError.invalidRequest)
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], any Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let photoResult):
                do {
                    let photos = try photoResult.map { try Photo(from: $0) }
                    let newPhotos = photos.filter { photo in
                        !self.photos.contains(where: { $0.id == photo.id })
                    }
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                } catch {
                    // TODO: log error
                    NotificationCenter.default.post(
                        name: ImagesListService.didFailNotification,
                        object: self,
                        userInfo: ["error": error]
                    )
                }
            case .failure(let error):
                // TODO: log error
                NotificationCenter.default.post(
                    name: ImagesListService.didFailNotification,
                    object: self,
                    userInfo: ["error": error]
                )
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let request = makeChangeLikeRequest(photoId: photoId, with: isLike ? "POST" : "DELETE") else {
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<PhotoLikeResult, any Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let likeResult):
                let photoResult = likeResult.photo
                guard let index = self.photos.firstIndex(where: {
                    $0.id == photoResult.id
                }) else {
                    return
                }
                
                let photo = self.photos[index]
                let newPhoto = Photo(
                    id: photo.id,
                    size: photo.size,
                    createdAt: photo.createdAt,
                    welcomeDescription: photo.welcomeDescription,
                    thumbImageURL: photo.thumbImageURL,
                    largeImageURL: photo.largeImageURL,
                    // isLiked: photoResult.likedByUser
                    isLiked: !photo.isLiked
                )
                
                self.photos[index] = newPhoto
                //self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
                
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    private func makePhotosNextPageURLRequest(_ page: Int) -> URLRequest? {
        guard let token = OAuth2TokenStorage().token else {
            assertionFailure("Missing auth token")
            return nil
        }
        
        return URLRequest.makeRequest(
            host: "api.unsplash.com",
            path: "/photos",
            queryItems: [URLQueryItem(name: "page", value: String(page))],
            headers: ["Authorization": "Bearer \(token)"]
        )
    }
    
    private func makeChangeLikeRequest(photoId: String, with method: String) -> URLRequest? {
        guard let token = OAuth2TokenStorage().token else {
            assertionFailure("Missing auth token")
            return nil
        }
        
        return URLRequest.makeRequest(
            host: "api.unsplash.com",
            path: "/photos/\(photoId)/like",
            method: method,
            headers: ["Authorization": "Bearer \(token)"]
        )
    }
    
    func resetPhotos() {
        photos = []
    }
}
