//
//  WatchManager.swift
//  Audy
//
//  Created by Sammy Yousif on 9/2/17.
//  Copyright © 2017 Sammy Yousif. All rights reserved.
//

import WatchKit
import WatchConnectivity

class WatchManager: NSObject {
    static let shared = WatchManager()
    
    var watchSession: WCSession?
    
    override init() {
        super.init()
        watchSession = WCSession.default()
        watchSession?.delegate = self
        watchSession?.activate()
    }
}

extension WatchManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Watch activated session")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let type = message["type"] as? String else { return }
        switch type {
        case "library":
            let trackDicts = message["data"] as! [[String: Any]]
            let tracks = trackDicts.map { Track(fromDictionary: $0) }
            MusicLibrary.shared.tracks.value += tracks
        default:
            break
        }
    }
}
