//
//  Library.swift
//  Audy
//
//  Created by Sammy Yousif on 8/31/17.
//  Copyright © 2017 Sammy Yousif. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

class MusicLibrary: NSObject {
    static let shared = MusicLibrary()
    
    let bag = DisposeBag()
    
    let refreshing = Variable<Bool>(false)
    
    let tracks = Variable<[Track]>([])
    
    override init() {
        super.init()
        Observable.combineLatest(
            Spotify.shared.loggedIn.asObservable(),
            Soundcloud.shared.loggedIn.asObservable()
            )
            .filter { $0 || $1 }
            .flatMapLatest { loggedIntoSpotify, loggedIntoSoundcloud -> Observable<[Track]> in
                var observables: [Observable<[Track]>] = []
                
                if loggedIntoSpotify {
                    observables.append(Spotify.shared.getLibrary())
                }
                
                if loggedIntoSoundcloud {
                    observables.append(Soundcloud.shared.getLikes())
                }
                
                return Observable.zip(observables).concatMap { trackLists -> Observable<[Track]> in
                    var combinedLists = trackLists[0]
                    if trackLists.count == 2 {
                        for (index, track) in trackLists[1].enumerated() {
                            var insertionIndex = index * 2 + 1
                            if insertionIndex > combinedLists.count {
                                insertionIndex = combinedLists.count
                            }
                            combinedLists.insert(track, at: insertionIndex)
                        }
                    }
//                    let combinedLists: [Track] = trackLists.reduce([]) { result, tracks -> [Track] in
//                        return result + tracks
//                    }
                    return Observable.just(combinedLists)
                }
            }
            .subscribe(onNext: { [weak self] tracks in
                self?.tracks.value = tracks
            }).addDisposableTo(self.bag)
    }
}
