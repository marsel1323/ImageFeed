//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 09.02.2025.
//

import UIKit

enum CellImageState {
    case loading
    case error
    case finished(UIImage)
}

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Static properties
    
    weak var delegate: ImagesListCellDelegate?
    static let reuseIdentifier = "ImagesListCell"
    private var imageState: CellImageState = .loading
    
    // MARK: - @IBOutlet properties
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
    }
    
    func config(with photo: Photo) {
        let placeholder = generatePlaceholderImage(bounds.size)
        guard let url = URL(string: photo.thumbImageURL) else { return }
        
        imageState = .loading
        
        cellImage.kf.indicatorType = .activity
        cellImage.kf.setImage(
            with: url,
            placeholder: placeholder
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let imageResult):
                self.imageState = .finished(imageResult.image)
            case .failure:
                self.imageState = .error
            }

            dateLabel.text = photo.createdAt?.dateString
            setIsLiked(photo.isLiked)
        }
    }
    
    func generatePlaceholderImage(_ size: CGSize) -> UIImage {
        let icon = UIImage(named: "placeholder")
        let backgroundColor: UIColor = .ypWhiteAlpha50
        
        return UIGraphicsImageRenderer(size: size).image { context in
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            guard let icon else { return }
            
            let iconSize = CGSize(width: size.width * 0.5, height: size.height * 0.5)
            let iconOrigin = CGPoint(x: (size.width - iconSize.width) / 2, y: (size.height - iconSize.height) / 2)
            icon.draw(in: CGRect(origin: iconOrigin, size: iconSize))
        }
    }
    
    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func setIsLiked(_ isLiked: Bool) {
        //let isLiked = self.photos[indexPath.row].isLiked
        likeButton.setImage(isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off"), for: .normal)
    }
}
