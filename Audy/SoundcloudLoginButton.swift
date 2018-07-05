//
//  SoundcloudLoginButton.swift
//  Audy
//
//  Created by Sammy Yousif on 8/30/17.
//  Copyright © 2017 Sammy Yousif. All rights reserved.
//

import UIKit

class SoundcloudLoginButton: UIButton {

    override open var isHighlighted: Bool {
        didSet {
            self.fade()
        }
    }
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        return label
    }()
    
    init(label: String, backgroundColor: UIColor) {
        super.init(frame: CGRect.zero)
        self.backgroundColor = backgroundColor
        self.label.text = label
        addSubview(self.label)
        self.label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    override func didMoveToSuperview() {
        self.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: UIScreen.main.bounds.width / 2, height: 44))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fade() {
        let opacity: Float = self.isHighlighted ? 0.5 : 1
        UIView.animate(withDuration: 0.25) {
            self.label.layer.opacity = opacity
        }
    }

}
