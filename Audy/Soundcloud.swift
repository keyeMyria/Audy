//
//  Soundcloud.swift
//  Audy
//
//  Created by Sammy Yousif on 8/30/17.
//  Copyright © 2017 Sammy Yousif. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import SwiftyJSON

class Soundcloud: NSObject {
    static let shared = Soundcloud()
    
    let bag = DisposeBag()
    
    var token: Variable<String?>!
    var loggedIn: Variable<Bool>!
    
    override init() {
        super.init()
        let val = UserDefaults.standard.string(forKey: "soundcloud")
        self.token = Variable<String?>(val)
        self.loggedIn = Variable<Bool>(val != nil)

        token.asObservable().subscribe(onNext: { [weak self] token in
            if let token = token {
                self?.loggedIn.value = true
                UserDefaults.standard.set(token, forKey: "soundcloud")
            }
            else {
                self?.loggedIn.value = false
                UserDefaults.standard.removeObject(forKey: "soundcloud")
            }
        }).addDisposableTo(bag)
    }
}

extension Soundcloud {
    func login() {
        NavigationController.shared.pushViewController(SoundcloudLoginController(), animated: true)
    }
}

extension Soundcloud {
    func getLikes() -> Observable<[Track]> {
        return Observable.create { observer in
            let url = URL(string: "https://api.soundcloud.com/me/favorites")!
            let parameters: Parameters = [
                "oauth_token": self.token.value!
            ]
            Alamofire
                .request(url, method: .get, parameters: parameters, encoding: URLEncoding(destination: .queryString))
                .validate()
                .responseJSON(queue: DispatchQueue.global(qos: .background)) { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        let tracks = json.arrayValue
                            .filter{ $0["streamable"].boolValue }
                            .map { data -> Track in
                                let id = data["id"].stringValue
                                let name = data["title"].stringValue
                                let artist = data["user", "username"].stringValue
                                let thumbnail = data["artwork_url"].stringValue
                                let artwork = thumbnail.replacingOccurrences(of: "large", with: "t500x500")
                                let duration = Double(data["duration"].intValue / 1000)
                                return Track(type: .soundcloud, id: id, name: name, artist: artist, duration: duration, artwork: artwork, thumbnail: thumbnail)
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
