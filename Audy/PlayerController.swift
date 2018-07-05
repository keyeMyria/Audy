//
//  PlayerController.swift
//  Audy
//
//  Created by Sammy Yousif on 8/31/17.
//  Copyright © 2017 Sammy Yousif. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

class PlayerController: UIViewController {
    static let minimizedHeight: CGFloat = 54
    
    let bag = DisposeBag()
    
    lazy var blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: blur)
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    lazy var playButton: PlayButton = {
        let button = PlayButton()
        button.addTarget(self, action: #selector(togglePlayback), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        
        view.addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(playButton)
        playButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().inset(10)
            make.left.equalToSuperview().offset(10)
            make.width.equalTo(playButton.snp.height)
        }
        
        Player.shared.nowPlaying.asObservable().subscribe(onNext: { [weak self] track in
            if let track = track {
                self?.playButton.track = track
            }
        }).addDisposableTo(bag)
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        view.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(PlayerController.minimizedHeight)
        }
    }
    
    func togglePlayback() {
        Player.shared.togglePlayback()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
