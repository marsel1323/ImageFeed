//
//  ViewController.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 08.02.2025.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController, ImagesListCellDelegate {
    let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    @IBOutlet private var tableView: UITableView!
    
    private var photos: [Photo] = []
    private var imagesListServiceObserver: NSObjectProtocol?
    private var imagesListServiceErrorObserver: NSObjectProtocol?
    
    //    private let currentDate = Date()
    
    //    private lazy var dateFormatter: DateFormatter = {
    //        let formatter = DateFormatter()
    //        formatter.dateStyle = .long
    //        formatter.timeStyle = .none
    //        return formatter
    //    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12,right: 0)
        
        setupNotificationObserver()
        ImagesListService.shared.fetchPhotosNextPage()
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = ImagesListService.shared.photos.count
        photos = ImagesListService.shared.photos
        
        guard oldCount != newCount else { return }
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map {
                IndexPath(row: $0, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func setupNotificationObserver() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                guard let self else { return }
                self.updateTableViewAnimated()
            }
        )
        
        //        imagesListServiceErrorObserver = NotificationCenter.default.addObserver(
        //                forName: ImagesListService.didFailNotification,
        //                object: nil,
        //                queue: .main,
        //                using: { [weak self] _ in
        //                    guard let self else { return }
        //                    self.showSomethingWentWrongError {
        //                        ImagesListService.shared.fetchPhotosNextPage()
        //                    }
        //                }
        //            )
    }
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        
        ImagesListService.shared.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            switch result {
            case .success:
                self.photos = ImagesListService.shared.photos
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
            case .failure(let error):
                print("Ошибка при лайке изображения: \(error)")
            }
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let imageListCell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row + 1 == photos.count else { return }
        ImagesListService.shared.fetchPhotosNextPage()
    }
}

extension ImagesListViewController {
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        //        guard let image = UIImage(named: photos[indexPath.row].thumbImageURL) else {
        //            return
        //        }
        //
        //        cell.cellImage.image = image
        //        cell.dateLabel.text = dateFormatter.string(from: currentDate)
        //
        //        let isLiked = indexPath.row % 2 == 0
        //        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        //        cell.likeButton.setImage(likeImage, for: .normal)
        cell.config(with: photos[indexPath.row])
        cell.delegate = self
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
        
        //        let controller = SingleImageViewController()
        //        controller.configure(with: photos[indexPath.row])
        //        controller.modalPresentationStyle = .fullScreen
        //        present(controller, animated: true)
        //
        //        controller.imageView.kf.setImage(with: photos[indexPath.row].largeImageURL) { [weak self] result in
        //
        //        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier,
           let viewController = segue.destination as? SingleImageViewController,
           let indexPath = sender as? IndexPath {
            let photo = ImagesListService.shared.photos[indexPath.row]
            guard let url = URL(string: photo.largeImageURL) else { return }
                        
            viewController.imageURL = url
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //        guard let image = UIImage(named: photos[indexPath.row].thumbImageURL) else {
        //            return 0
        //        }
        let image = photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        //        let imageViewWidth = view.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        
        return cellHeight
    }
}
