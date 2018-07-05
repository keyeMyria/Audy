//
//  SoundcloudLoginController.swift
//  Audy
//
//  Created by Sammy Yousif on 8/30/17.
//  Copyright © 2017 Sammy Yousif. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

class SoundcloudLoginController: UIViewController {
    
    lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = false
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_90) AppleWebKit/602.4.8 (KHTML, like Gecko) Version/10.0.3 Safari/602.4.8"
        return webView
    }()
    
    lazy var facebookButton: SoundcloudLoginButton = {
        let button = SoundcloudLoginButton(label: "Facebook", backgroundColor: UIColor.blue)
        button.addTarget(self, action: #selector(goToFacebook), for: .touchUpInside)
        return button
    }()
    
    lazy var soundcloudButton: SoundcloudLoginButton = {
        let button = SoundcloudLoginButton(label: "Soundcloud", backgroundColor: Colors.soundcloudOrange)
        button.addTarget(self, action: #selector(goToSoundcloud), for: .touchUpInside)
        return button
    }()
    
    lazy var cancelButton: SoundcloudLoginButton = {
        let button = SoundcloudLoginButton(label: "Cancel", backgroundColor: UIColor.red)
        button.addTarget(self, action: #selector(cancelLogin), for: .touchUpInside)
        return button
    }()
    
    lazy var tokenButton: SoundcloudLoginButton = {
        let button = SoundcloudLoginButton(label: "Get Token", backgroundColor: UIColor.blue)
        button.addTarget(self, action: #selector(getToken), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        
        webView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(88)
        }
        
        guard let url = URL(string: "https://facebook.com") else { return }
        webView.load(URLRequest(url: url))
        
        view.addSubview(facebookButton)
        facebookButton.snp.makeConstraints { make in
            make.top.equalTo(webView.snp.bottom)
            make.left.equalToSuperview()
        }
        
        view.addSubview(soundcloudButton)
        soundcloudButton.snp.makeConstraints { make in
            make.top.equalTo(webView.snp.bottom)
            make.right.equalToSuperview()
        }
        
        view.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
        }
        
        view.addSubview(tokenButton)
        tokenButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goToFacebook() {
        guard let url = URL(string: "https://facebook.com") else { return }
        webView.load(URLRequest(url: url))
    }
    
    func goToSoundcloud() {
        guard let url = URL(string: "https://soundcloud.com") else { return }
        webView.load(URLRequest(url: url))
    }
    
    func cancelLogin() {
        NavigationController.shared.popViewController(animated: true)
    }
    
    func getToken() {
        webView.evaluateJavaScript("document.cookie.split(';').find(val => val.indexOf('oauth_token=') > -1).replace(' oauth_token=', '')") { result, error in
            if let error = error {
                print("\(error)")
            }
            else {
                if let token = result as? String {
                    Soundcloud.shared.token.value = token
                    NavigationController.shared.popViewController(animated: true)
                }
            }
        }
    }

}

extension SoundcloudLoginController: WKNavigationDelegate {
    
}
