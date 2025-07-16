//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 14.07.2025.
//

import Foundation

public protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    var photosCount: Int { get }
    func viewDidLoad()
    func photo(at index: Int) -> Photo?
    func updatePhotos()
    func fetchNextPhotosPageIfNeeded(_ index: Int)
    func changeLikeForPhoto(at index: Int, _ completion: @escaping (Result<Bool, Error>) -> Void)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    weak var view: ImagesListViewControllerProtocol?
    var photosCount: Int {
        return photos.count
    }
    
    private var photos: [Photo] = []
    private var imagesListServiceObserver: NSObjectProtocol?
}

extension ImagesListPresenter {
    func viewDidLoad() {
        view?.presenter = self
        
        setupNotificationObserver()
        ImagesListService.shared.fetchPhotosNextPage()
    }
    
    func photo(at index: Int) -> Photo? {
        guard index >= 0 && index < photos.count else {
            return nil
        }
        return photos[index]
    }
    
    func updatePhotos() {
        guard let view = view else {
            preconditionFailure("view doesn't exist")
        }
        
        let oldCount = photos.count
        let newCount = ImagesListService.shared.photos.count
        photos = ImagesListService.shared.photos
        
        guard oldCount != newCount else { return }
        
        view.updateTableViewAnimated(from: oldCount, to: newCount)
    }
    
    func fetchNextPhotosPageIfNeeded(_ index: Int) {
        guard index + 1 == photos.count else { return }
        ImagesListService.shared.fetchPhotosNextPage()
    }
    
    func changeLikeForPhoto(at index: Int, _ completion: @escaping (Result<Bool, any Error>) -> Void) {
        guard let photo = photo(at: index) else { return }
        
        ImagesListService.shared.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success:
                self.photos = ImagesListService.shared.photos
                completion(.success(self.photos[index].isLiked))
            case .failure(let error):
                print("Error while changing like: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func setupNotificationObserver() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                guard let self else { return }
                
                self.updatePhotos()
            }
        )
    }
}
