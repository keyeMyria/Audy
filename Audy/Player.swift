//
//  Player.swift
//  Audy
//
//  Created by Sammy Yousif on 8/31/17.
//  Copyright © 2017 Sammy Yousif. All rights reserved.
//

import Foundation
import AVFoundation
import Alamofire
import SwiftyJSON
import RxSwift
import MediaPlayer
import SDWebImage

enum LoopType {
    case none
    case list
    case track
}

class Player: NSObject {
    static let shared = Player()
    
    let bag = DisposeBag()
    
    let avPlayer = AVPlayer()
    var avPlayerItem: AVPlayerItem? {
        didSet {
            if let item = avPlayerItem {
                playAV(item)
            }
        }
    }
    
    var spotifyPlayer: SPTAudioStreamingController?
    var spotifyReady = false
    var spotifyPlaying: Bool {
        get {
            if let player = spotifyPlayer, let state = player.playbackState, state.isPlaying {
                return true
            }
            return false
        }
    }
    
    var shuffle = Variable<Bool>(false)
    var loop = Variable<LoopType>(.none)
    
    var currentTrack: Track? {
        get {
            if let index = currentIndex, let list = currentList {
                return list[index]
            }
            else {
                return nil
            }
        }
    }
    var currentList: [Track]?
    var currentIndex: Int? {
        didSet {
            if let track = currentTrack {
                setupTrack(track)
            }
        }
    }
    
    let nowPlaying = Variable<Track?>(nil)
    let isPlaying = Variable<Bool>(false)
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(playNext), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayerItem)
        
        Spotify.shared.loggedIn.asObservable().subscribe(onNext: { [weak self] loggedIn in
            if loggedIn {
                self?.startSpotifyPlayer()
            }
        }).addDisposableTo(bag)
        
        setupNowPlayingInfoCenter()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupNowPlayingInfoCenter() {
        UIApplication.shared.beginReceivingRemoteControlEvents();
        MPRemoteCommandCenter.shared().playCommand.addTarget { [weak self] event in
            self?.resume()
            return .success
        }
        MPRemoteCommandCenter.shared().pauseCommand.addTarget { [weak self] event in
            self?.pause()
            return .success
        }
//        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget { [weak self] event in
//            self?.next()
//            return .success
//        }
//        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget { [weak self] event in
//            self?.prev()
//            return .success
//        }
    }
    
    func startSpotifyPlayer() {
        if spotifyPlayer != nil { return }
        spotifyPlayer = SPTAudioStreamingController.sharedInstance()
        do {
            try spotifyPlayer?.start(withClientId: Secrets.spotify.clientId)
            spotifyPlayer?.playbackDelegate = self
            spotifyPlayer?.delegate = self
            spotifyPlayer?.login(withAccessToken: Spotify.shared.accessToken!)
        }
        catch let error {
            print("start up error \(error)")
        }
    }
    
    func selectTrack(list: [Track], index: Int = 0) {
        self.currentList = list
        self.currentIndex = index
    }
    
    func playAV(_ item: AVPlayerItem) {
        avPlayer.pause()
        avPlayer.seek(to: kCMTimeZero)
        avPlayer.replaceCurrentItem(with: item)
        avPlayer.play()
    }
    
    func playNext() {
        if loop.value == .track, let index = currentIndex {
            currentIndex = index
        }
        else if loop.value == .list, let index = currentIndex, let list = currentList, index == list.count - 1 {
            currentIndex = 0
        }
        else if let index = currentIndex, let list = currentList, index < list.count - 1 {
            currentIndex = index + 1
        }
        else {
            pausePlayback()
            nowPlaying.value = nil
            isPlaying.value = false
        }
    }
    
    func pause() {
        pausePlayback()
        if var mediaInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo {
            mediaInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0
            MPNowPlayingInfoCenter.default().nowPlayingInfo = mediaInfo
        }
        isPlaying.value = false
    }
    
    func resume() {
        if let track = currentTrack {
            resumePlayback(track)
            if var mediaInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo {
                mediaInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
                MPNowPlayingInfoCenter.default().nowPlayingInfo = mediaInfo
            }
        }
    }
    
    func pausePlayback() {
        if spotifyPlaying {
            spotifyPlayer?.setIsPlaying(false) { error in
                if let error = error {
                    print("setIsPlayingError: \(error)")
                }
            }
        }
        if avPlayer.isPlaying {
            avPlayer.pause()
        }
    }
    
    func resumePlayback(_ track: Track) {
        switch track.type {
        case .soundcloud:
            avPlayer.play()
        case .spotify:
            spotifyPlayer?.setIsPlaying(true) { error in
                if let error = error {
                    print("setIsPlayingError: \(error)")
                }
            }
        }
    }
    
    func togglePlayback() {
        if spotifyPlaying || avPlayer.isPlaying {
            pause()
        }
        else if let track = currentTrack {
            resumePlayback(track)
        }
    }
    
    func setupTrack(_ track: Track) {
        nowPlaying.value = track
        isPlaying.value = true
        pausePlayback()
        setMediaInfo(track)
        switch track.type {
        case .soundcloud:
            setPlayerItem(track)
        case .spotify:
            setSpotifyTrack(track)
        }
    }
    
    func setMediaInfo(_ track: Track) {
        let key = SDWebImageManager.shared().cacheKey(for: track.artwork)
        let image = SDImageCache.shared().imageFromCache(forKey: key)
        var elapsedTime: TimeInterval = 0
        switch track.type {
        case .soundcloud:
            if let time = avPlayerItem?.currentTime() {
                elapsedTime = CMTimeGetSeconds(time)
            }
        case .spotify:
            if let state = spotifyPlayer?.playbackState {
                elapsedTime = state.position
            }
        }
        if let image = image {
            let artwork = makeArtwork(track, image: image)
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [
                MPMediaItemPropertyTitle: track.name,
                MPMediaItemPropertyArtist: track.artist,
                MPMediaItemPropertyPlaybackDuration: track.duration,
                MPNowPlayingInfoPropertyElapsedPlaybackTime: elapsedTime,
                MPNowPlayingInfoPropertyPlaybackRate: 1,
                MPMediaItemPropertyArtwork: artwork
            ]
            return
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: track.name,
            MPMediaItemPropertyArtist: track.artist,
            MPMediaItemPropertyPlaybackDuration: track.duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: elapsedTime,
            MPNowPlayingInfoPropertyPlaybackRate: 1
        ]
        Alamofire.request(track.artwork!).responseData(queue: DispatchQueue.global(qos: .background)) { [weak self] response in
            if let data = response.data {
                let image = UIImage(data: data)
                if let image = image {
                    switch track.type {
                    case .soundcloud:
                        if let time = self?.avPlayerItem?.currentTime() {
                            elapsedTime = CMTimeGetSeconds(time)
                        }
                    case .spotify:
                        if let state = self?.spotifyPlayer?.playbackState {
                            elapsedTime = state.position
                        }
                    }
                    guard let artwork = self?.makeArtwork(track, image: image) else { return }
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = [
                        MPMediaItemPropertyTitle: track.name,
                        MPMediaItemPropertyArtist: track.artist,
                        MPMediaItemPropertyPlaybackDuration: track.duration,
                        MPNowPlayingInfoPropertyElapsedPlaybackTime: elapsedTime,
                        MPNowPlayingInfoPropertyPlaybackRate: 1,
                        MPMediaItemPropertyArtwork: artwork,
                    ]
                }
            }
        }
    }
    
    func makeArtwork(_ track: Track, image: UIImage) -> MPMediaItemArtwork {
        var dimension: Int
        switch track.type {
        case .spotify:
            dimension = 640
        case .soundcloud:
            dimension = 500
        }
        let size = CGSize(width: dimension, height: dimension)
        return MPMediaItemArtwork(boundsSize: size) { size -> UIImage in
            image
        }
    }
    
    func setPlayerItem(_ track: Track) {
        guard let url = URL(string: "https://api.soundcloud.com/tracks/\(track.id)/stream") else { return }
        let parameters: Parameters = [
            "client_id": Secrets.soundcloud.clientId,
            ]
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding(destination: .queryString))
            .response(queue: DispatchQueue.global(qos: .background)) { [unowned self] response in
                guard let response = response.response else { return }
                let string = "\(response)"
                let url = string.components(separatedBy: "URL: ")[1].components(separatedBy: " }")[0]
                if url.characters.count > 0 {
                    guard let url = URL(string: url) else { return }
                    self.avPlayerItem = AVPlayerItem(url: url)
                }
        }
    }
    
    func setSpotifyTrack(_ track: Track) {
        if !spotifyReady { return }
        spotifyPlayer?.playSpotifyURI(track.id, startingWith: 0, startingWithPosition: 0, callback: { error in
            if let error = error {
                print("playSpotifyURI: \(error)")
            }
        })
    }
    
    
}

extension Player: SPTAudioStreamingDelegate {
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        spotifyReady = true
        if let track = currentTrack, track.type == .spotify {
            setSpotifyTrack(track)
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveError error: Error!) {
        print("received error \(error)")
    }
}

extension Player: SPTAudioStreamingPlaybackDelegate {
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
        playNext()
    }
}
