//
//  PlayButton.swift
//  Audy
//
//  Created by Sammy Yousif on 9/1/17.
//  Copyright © 2017 Sammy Yousif. All rights reserved.
//

import UIKit
import SnapKit

class PlayButtonArtwork: UIView {
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
        image.layer.cornerRadius = PlayButtonArtwork.cornerRadius
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        isUserInteractionEnabled = false
        layer.shadowColor = Colors.shadow.cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 3
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.cornerRadius = PlayButtonArtwork.cornerRadius
        addSubview(image)
        image.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PlayButton: UIButton {

    override open var isHighlighted: Bool {
        didSet {
            if !isEnabled { return }
            self.fade()
        }
    }
    
    var track: Track? {
        didSet {
            if let track = track {
                artwork.url = track.artwork
            }
            else {
                isEnabled = false
            }
        }
    }
    
    lazy var artwork: PlayButtonArtwork = {
        let artwork = PlayButtonArtwork()
        return artwork
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        addSubview(artwork)
        artwork.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fade() {
        let opacity: Float = self.isHighlighted ? 0 : 1
        UIView.animate(withDuration: 0.25) {
            self.artwork.layer.shadowOpacity = opacity
        }
    }

}
