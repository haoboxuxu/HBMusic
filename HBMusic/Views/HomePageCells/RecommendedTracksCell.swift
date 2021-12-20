//
//  RecommendedCell.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/23.
//

import UIKit

class RecommendedTracksCell: UICollectionViewCell {
    
    static let identifier = "RecommendedTracksCell"
    
    public var isOwner = false
    
    var swipeGesture: UIPanGestureRecognizer!
    
    let deleteLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "delete"
        return label
    }()
    
    private var albumCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "music.quarternote.3")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5
        return imageView
    }()
    
    private var trackNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    private var artistNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .thin)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemBackground
        backgroundColor = .systemRed
        
        contentView.addSubview(albumCoverImageView)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
        contentView.clipsToBounds = true
        
        self.insertSubview(deleteLabel, belowSubview: self.contentView)
        setUpSwipeGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        albumCoverImageView.frame = CGRect(x: 5, y: 2, width: contentView.height-4, height: contentView.height-4)
        trackNameLabel.frame = CGRect(x: albumCoverImageView.right+10, y: 0,
                                      width: contentView.width-albumCoverImageView.right-15, height: contentView.height/2)
        artistNameLabel.frame = CGRect(x: albumCoverImageView.right+10, y: contentView.height/2,
                                       width: contentView.width-albumCoverImageView.right-15, height: contentView.height/2)
        if (swipeGesture.state == UIGestureRecognizer.State.changed) {
            let p: CGPoint = swipeGesture.translation(in: self)
            let width = self.contentView.frame.width
            let height = self.contentView.frame.height
            self.contentView.frame = CGRect(x: p.x,y: 0, width: width, height: height);
            self.deleteLabel.frame = CGRect(x: p.x + width + deleteLabel.frame.size.width, y: 0, width: 100, height: height)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackNameLabel.text = nil
        artistNameLabel.text = nil
        albumCoverImageView.image = nil
    }
    
    func config(with viewModel: RecommendedTracksCellVM, isOwner: Bool = false) {
        trackNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
        albumCoverImageView.hbSetImage(with: viewModel.artWorkURL, placeholderImage: nil, completion: nil)
        if !isOwner {
            self.removeGestureRecognizer(swipeGesture)
        }
    }
}

// Swipe Delete Gesture
extension RecommendedTracksCell: UIGestureRecognizerDelegate {
    private func setUpSwipeGesture() {
        swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        swipeGesture.delegate = self
        self.addGestureRecognizer(swipeGesture)
    }
    
    @objc func didSwipe(_ pan: UIPanGestureRecognizer) {
        if pan.state == UIGestureRecognizer.State.began {
            return
        } else if pan.state == UIGestureRecognizer.State.changed {
            self.setNeedsLayout()
        } else {
            if abs(pan.velocity(in: self).x) > 500 {
                let collectionView: UICollectionView = self.superview as! UICollectionView
                let indexPath: IndexPath = collectionView.indexPathForItem(at: self.center)!
                collectionView.delegate?.collectionView!(collectionView, performAction: #selector(didSwipe(_:)), forItemAt: indexPath, withSender: nil)
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                })
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return abs((swipeGesture.velocity(in: swipeGesture.view)).x) > abs((swipeGesture.velocity(in: swipeGesture.view)).y)
    }
}
