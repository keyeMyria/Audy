//
//  WatchManager.swift
//  Audy
//
//  Created by Sammy Yousif on 9/2/17.
//  Copyright © 2017 Sammy Yousif. All rights reserved.
//

import Foundation
import WatchConnectivity
import RxSwift

class WatchManager: NSObject {
    static let shared = WatchManager()
    
    fileprivate let bag = DisposeBag()
    
    fileprivate var watchSession: WCSession?
    
    fileprivate let sessionActive = Variable<Bool>(false)
    
    override init() {
        super.init()
        
        Observable
            .combineLatest(sessionActive.asObservable(), MusicLibrary.shared.tracks.asObservable())
            .filter { $0.0 }
            .subscribe(onNext: { (active, tracks) in
                let dict: [String: Any] = [
                    "type": "library",
                    "data": tracks.map { $0.serialize() }
                ]
                self.watchSession?.sendMessage(dict, replyHandler: nil)
            }).addDisposableTo(bag)
        
        
        watchSession = WCSession.default()
        watchSession?.delegate = self
        watchSession?.activate()
    }
    
    func play(_ message: [String : Any]) {
        guard let source = message["source"] as? String else { return }
        switch source {
        case "library":
            guard let index = message["index"] as? Int else { return }
            Player.shared.selectTrack(list: MusicLibrary.shared.tracks.value, index: index)
        default:
            break
        }
    }
}

extension WatchManager: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        sessionActive.value = true
    }
    
    public func sessionDidBecomeInactive(_ session: WCSession) {
        print("session did become inactive")
    }
    
    public func sessionDidDeactivate(_ session: WCSession) {
        sessionActive.value = false
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let type = message["type"] as? String else { return }
        switch type {
        case "play":
            play(message)
        default:
            break
        }
    }
}
