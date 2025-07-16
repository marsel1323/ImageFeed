//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 03.06.2025.
//

import Foundation

enum PhotoUpdateError: Error {
    case photoNotFound
}

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
        
        guard let request = makePhotosNextPageURLRequest(nextPage) else { return }
        
        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], any Error>) in
            guard let self else { return }
            
            defer { self.task = nil }
            
            switch result {
            case .success(let photoResults):
                self.handlePhotoResults(photoResults, nextPage: nextPage)
            case .failure(let error):
                self.handlePhotosLoadingError(error)
            }
        }
        
        task?.resume()
    }
    
    func handlePhotoResults(_ photoResults: [PhotoResult], nextPage: Int) {
        do {
            let newPhotos = try photoResults
                .map { try Photo(from: $0) }
                .filter { newPhoto in
                    !self.photos.contains(where: { $0.id == newPhoto.id })
                }
            
            photos.append(contentsOf: newPhotos)
            lastLoadedPage = nextPage
            
            NotificationCenter.default.post(
                name: ImagesListService.didChangeNotification,
                object: self
            )
        } catch {
            handlePhotosLoadingError(error)
        }
    }
    
    private func handlePhotosLoadingError(_ error: Error) {
        print("Ошибка при загрузке фотографий: \(error.localizedDescription)")
        NotificationCenter.default.post(
            name: ImagesListService.didFailNotification,
            object: self,
            userInfo: ["error": error]
        )
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let request = makeChangeLikeRequest(photoId: photoId, with: isLike ? "POST" : "DELETE") else {
            return
        }

        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<PhotoLikeResult, any Error>) in
            guard let self else { return }

            switch result {
            case .success(let likeResult):
                self.updatePhotoLikeStatus(with: likeResult.photo, completion: completion)
            case .failure(let error):
                print("❌ Ошибка при изменении лайка: \(error)")
                completion(.failure(error))
            }
        }

        task.resume()
    }

    func updatePhotoLikeStatus(with updatedPhoto: PhotoResult, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let index = photos.firstIndex(where: { $0.id == updatedPhoto.id }) else {
            print("⚠️ Не удалось найти фото с id: \(updatedPhoto.id)")
            completion(.failure(PhotoUpdateError.photoNotFound))
            return
        }

        let oldPhoto = photos[index]
        let newPhoto = Photo(
            id: oldPhoto.id,
            size: oldPhoto.size,
            createdAt: oldPhoto.createdAt,
            welcomeDescription: oldPhoto.welcomeDescription,
            thumbImageURL: oldPhoto.thumbImageURL,
            largeImageURL: oldPhoto.largeImageURL,
            isLiked: !oldPhoto.isLiked
        )

        photos[index] = newPhoto
        completion(.success(()))
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
