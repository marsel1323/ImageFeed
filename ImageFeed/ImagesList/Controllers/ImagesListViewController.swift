//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 08.02.2025.
//

import UIKit
//import Kingfisher

public protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    func updateTableViewAnimated(from: Int, to: Int)
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    @IBOutlet var tableView: UITableView!
    
    var presenter: ImagesListPresenterProtocol?
    private lazy var alertPresenter = AlertPresenter(viewController: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.view = self
        presenter?.viewDidLoad()
    }
    
    func updateTableViewAnimated(from: Int, to: Int) {
        tableView.performBatchUpdates {
            let indexPaths = (from..<to).map {
                IndexPath(row: $0, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let presenter else { preconditionFailure("Presenter doesn't exist") }
        return presenter.photosCount
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
        if ProcessInfo.processInfo.arguments.contains("UITests") { return }
        presenter?.fetchNextPhotosPageIfNeeded(indexPath.row)
    }
}

extension ImagesListViewController {
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let photo = presenter?.photo(at: indexPath.row) else {
            preconditionFailure("Index out of range")
        }
        cell.config(with: photo)
        cell.delegate = self
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier,
           let viewController = segue.destination as? SingleImageViewController,
           let indexPath = sender as? IndexPath {
            guard let presenter else {
                preconditionFailure("Presenter doesn't exist")
            }
            guard let photo = presenter.photo(at: indexPath.row) else {
                preconditionFailure("Index out of range")
            }

            guard let url = URL(string: photo.largeImageURL) else { return }
            
            viewController.imageURL = url
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let presenter else {
            preconditionFailure("Presenter doesn't exist")
        }
        guard let image = presenter.photo(at: indexPath.row) else {
            preconditionFailure("Index out of range")
        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        
        return cellHeight
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        UIBlockingProgressHUD.show()
        
        presenter?.changeLikeForPhoto(at: indexPath.row) { result in
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let isLiked):
                cell.setIsLiked(isLiked)
            case .failure(let error):
                print("Error while changing like: \(error)")
            }
        }
    }
}
