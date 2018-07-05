//
//  Track.swift
//  Audy
//
//  Created by Sammy Yousif on 9/1/17.
//  Copyright © 2017 Sammy Yousif. All rights reserved.
//

import Foundation

enum TrackType: Int {
    case spotify = 0
    case soundcloud = 1
}

struct Track {
    let type: TrackType
    let id: String
    let name: String
    let artist: String
    let duration: TimeInterval
    let artwork: URL?
    let thumbnail: URL?
    
    init(type: TrackType, id: String, name: String, artist: String, duration: TimeInterval, artwork: String, thumbnail: String) {
        self.type = type
        self.id = id
        self.name = name
        self.artist = artist
        self.duration = duration
        self.artwork = URL(string: artwork)
        self.thumbnail = URL(string: thumbnail)
    }
    
    init(fromDictionary dictionary: [String:Any?]) {
        self.type = TrackType(rawValue: dictionary["type"] as! Int)!
        self.id = dictionary["id"] as! String
        self.name = dictionary["name"] as! String
        self.artist = dictionary["artist"] as! String
        self.duration = dictionary["duration"] as! TimeInterval
        self.artwork = URL(string: dictionary["artwork"] as! String)
        self.thumbnail = URL(string: dictionary["thumbnail"] as! String)
    }
    
    func serialize() -> [String:Any?] {
        return [
            "type": self.type.rawValue,
            "id": self.id,
            "name": self.name,
            "artist": self.artist,
            "duration": self.duration,
            "artwork": self.artwork?.absoluteString,
            "thumbnail": self.thumbnail?.absoluteString,
        ]
    }
}
