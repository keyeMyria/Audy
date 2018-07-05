//
//  ViewController.swift
//  Audy
//
//  Created by Sammy Yousif on 8/28/17.
//  Copyright © 2017 Sammy Yousif. All rights reserved.
//

import UIKit
import RxSwift

class AccountsController: UIViewController {
    
    lazy var spotifyLoginButton: LoginButton = {
        let button = LoginButton(label: "Login to Spotify", backgroundColor: Colors.spotifyGreen)
        button.addTarget(self, action: #selector(loginToSpotify), for: .touchUpInside)
        button.isEnabled = !Spotify.shared.loggedIn.value
        return button
    }()
    
    lazy var soundcloudLoginButton: LoginButton = {
        let button = LoginButton(label: "Login to Soundcloud", backgroundColor: Colors.soundcloudOrange)
        button.addTarget(self, action: #selector(loginToSoundcloud), for: .touchUpInside)
        button.isEnabled = !Soundcloud.shared.loggedIn.value
        return button
    }()
    
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(soundcloudLoginButton)
        soundcloudLoginButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(70)
        }
        
        view.addSubview(spotifyLoginButton)
        spotifyLoginButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(soundcloudLoginButton.snp.top).offset(-25)
        }
        
        Soundcloud.shared.loggedIn.asObservable().subscribe(onNext: { [weak self] loggedIn in
            self?.soundcloudLoginButton.isEnabled = !loggedIn
        }).addDisposableTo(bag)
        
        Spotify.shared.loggedIn.asObservable().subscribe(onNext: { [weak self] loggedIn in
            self?.spotifyLoginButton.isEnabled = !loggedIn
        }).addDisposableTo(bag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginToSoundcloud() {
        if !soundcloudLoginButton.isEnabled { return }
        Soundcloud.shared.login()
    }

    func loginToSpotify() {
        if !spotifyLoginButton.isEnabled { return }
        Spotify.shared.login()
    }

}

