//
//  Spotify.swift
//  Audy
//
//  Created by Sammy Yousif on 8/30/17.
//  Copyright © 2017 Sammy Yousif. All rights reserved.
//

import Foundation
import RxSwift
import SafariServices
import SwiftyJSON
import Alamofire

class Spotify: NSObject {
    static let kRedirectURL = "audy://spotify/auth"
    static let shared = Spotify()
    
    let auth = SPTAuth.defaultInstance()
    
    var session: SPTSession? {
        get {
            return auth?.session
        }
    }
    
    var accessToken: String? {
        get {
            if let session = session, session.isValid() {
                return session.accessToken
            }
            else {
                return nil
            }
        }
    }
    
    var refreshToken: String? = UserDefaults.standard.string(forKey: "spotifyRefresh") {
        didSet {
            if let token = refreshToken {
                UserDefaults.standard.set(token, forKey: "spotifyRefresh")
            }
        }
    }
    
    var loggedIn: Variable<Bool>!
    
    var safariVC: SFSafariViewController?
    
    override init() {
        super.init()
        guard let auth = auth else { return }
        auth.clientID = Secrets.spotify.clientId
        auth.sessionUserDefaultsKey = "spotify"
        
        if let session = session {
            let valid = session.isValid()
            loggedIn = Variable<Bool>(valid)
            if !valid {
                refresh()
            }
            else {
                startRefreshTimer()
            }
        }
        else {
            loggedIn = Variable<Bool>(false)
        }
    }
    
    func refresh() {
        guard let refreshToken = refreshToken else { return }
        guard let url = URL(string: "https://accounts.spotify.com/api/token") else { return }
        let parameters: Parameters = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "client_id": Secrets.spotify.clientId,
            "client_secret": Secrets.spotify.clientSecret
        ]
        Alamofire.request(url, method: .post, parameters: parameters).validate().responseJSON { [weak self] response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let accessToken = json["access_token"].stringValue
                let expiresIn = json["expires_in"].doubleValue
                guard let username = self?.session?.canonicalUsername else { return }
                let session = SPTSession.init(userName: username, accessToken: accessToken, expirationTimeInterval: expiresIn)
                self?.auth?.session = session
                self?.loggedIn.value = true
                self?.startRefreshTimer()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func startRefreshTimer() {
        guard let session = session else { return }
        let refreshTime = session.expirationDate.addingTimeInterval(-300)
        let timer = Timer(fireAt: refreshTime, interval: 0, target: self, selector: #selector(refresh), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: .commonModes)
    }
    
    func login() {
        let scopes = [
            "playlist-read-private",
            "playlist-read-collaborative",
            "playlist-modify-public",
            "playlist-modify-private",
            "streaming",
            "user-library-read",
            "user-library-modify",
            "user-read-playback-state",
            "user-modify-playback-state",
            "user-read-currently-playing"
        ].joined(separator: "%20")
        guard let url = URL(string: "https://accounts.spotify.com/authorize?client_id=\(Secrets.spotify.clientId)&response_type=code&redirect_uri=\(Spotify.kRedirectURL)&scope=\(scopes)") else { return }
        safariVC = SFSafariViewController(url: url)
        safariVC?.delegate = self
        NavigationController.shared.present(safariVC!, animated: true, completion: nil)
    }
    
    func handleLogin(_ url: URL) {
        safariVC?.dismiss(animated: true, completion: nil)
        guard let code = url["code"] else { return }
        guard let url = URL(string: "https://accounts.spotify.com/api/token") else { return }
        let parameters: Parameters = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": Spotify.kRedirectURL,
            "client_id": Secrets.spotify.clientId,
            "client_secret": Secrets.spotify.clientSecret
        ]
        Alamofire.request(url, method: .post, parameters: parameters).validate().responseJSON { [weak self] response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let accessToken = json["access_token"].stringValue
                let expiresIn = json["expires_in"].doubleValue
                self?.refreshToken = json["refresh_token"].stringValue
                guard let meURL = URL(string: "https://api.spotify.com/v1/me") else { return }
                let headers: HTTPHeaders = [
                    "Authorization": "Bearer \(accessToken)"
                ]
                Alamofire.request(meURL, method: .get, headers: headers).validate().responseJSON { [weak self] response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        let username = json["id"].stringValue
                        let session = SPTSession.init(userName: username, accessToken: accessToken, expirationTimeInterval: expiresIn)
                        self?.auth?.session = session
                        self?.loggedIn.value = true
                        self?.startRefreshTimer()
                    case .failure(let error):
                        print(error)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getLibrary() -> Observable<[Track]> {
        return Observable.create { [weak self] observer in
            guard let accessToken = self?.accessToken else {
                self?.loggedIn.value = false
                observer.on(.next([]))
                observer.on(.completed)
                return Disposables.create()
            }
            let url = URL(string: "https://api.spotify.com/v1/me/tracks")!
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(accessToken)"
            ]
            Alamofire
                .request(url, method: .get, headers: headers)
                .validate()
                .responseJSON(queue: DispatchQueue.global(qos: .background)) { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        let tracks = json["items"].arrayValue
                            .map { data -> Track in
                                let trackData = data["track"]
                                let id = trackData["uri"].stringValue
                                let name = trackData["name"].stringValue
                                let artist = trackData["artists"].arrayValue
                                    .map { data -> String in
                                        return data["name"].stringValue
                                    }
                                    .joined(separator: ", ")
                                let albumImages = trackData["album", "images"].arrayValue
                                let thumbnail = albumImages[1]["url"].stringValue
                                let artwork = albumImages[0]["url"].stringValue
                                let duration = Double(trackData["duration_ms"].intValue / 1000)
                                return Track(type: .spotify, id: id, name: name, artist: artist, duration: duration, artwork: artwork, thumbnail: thumbnail)
                        }
                        observer.on(.next(tracks))
                    case .failure(let error):
                        print(error)
                        observer.on(.next([]))
                        break
                    }
                    observer.on(.completed)
            }

            return Disposables.create()
        }
    }
}

extension Spotify: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
