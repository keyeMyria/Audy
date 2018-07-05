//
//  TrackCell.swift
//  Audy
//
//  Created by Sammy Yousif on 8/31/17.
//  Copyright © 2017 Sammy Yousif. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage

class TrackCellArtwork: UIView {
    static let cornerRadius: CGFloat = 3
    var url: URL? {
        didSet {
            if let url = url {
                image.sd_setImage(with: url)
            }
        }
    }
    
    lazy var image: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = UIColor.gray
        image.layer.cornerRadius = TrackCellArtwork.cornerRadius
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        
        layer.shadowColor = Colors.shadow.cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 3
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.cornerRadius = TrackCellArtwork.cornerRadius
        
        addSubview(image)
        image.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TrackCell: UICollectionViewCell {
    static let identifier = "trackCell"
    
    var track: Track? {
        didSet {
            if let track = track {
                let url = track.thumbnail
                artwork.url = url
                titleLabel.text = track.name
                artistLabel.text = track.artist
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            let backgroundColor: UIColor = self.isHighlighted ? Colors.disabledButtonGray : UIColor.white
            UIView.animate(withDuration: 0.5) {
                self.backgroundColor = backgroundColor
            }
        }
    }
    
    lazy var artwork: TrackCellArtwork = {
        let view = TrackCellArtwork()
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Medium", size: 12)
        label.textColor = UIColor.black
        return label
    }()
    
    lazy var artistLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Regular", size: 12)
        label.textColor = UIColor.gray
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        
        addSubview(artwork)
        artwork.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().inset(10)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(artwork.snp.height)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalTo(artwork.snp.right).offset(10)
            make.right.equalToSuperview().inset(20)
        }
        
        addSubview(artistLabel)
        artistLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(10)
            make.left.equalTo(artwork.snp.right).offset(10)
            make.right.equalToSuperview().inset(20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
