//
//  LibraryInterfaceController.swift
//  Audy
//
//  Created by Sammy Yousif on 9/1/17.
//  Copyright © 2017 Sammy Yousif. All rights reserved.
//

import WatchKit
import Foundation
import RxSwift
import SDWebImage
import WatchConnectivity

class LibraryInterfaceController: WKInterfaceController {

    @IBOutlet var trackTable: WKInterfaceTable!
    
    let bag = DisposeBag()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        MusicLibrary.shared.tracks.asObservable().subscribe(onNext: { [weak self] tracks in
            self?.setupTable(with: tracks)
        }).addDisposableTo(bag)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func setupTable(with tracks: [Track]) {
        trackTable.setNumberOfRows(tracks.count, withRowType: "TrackRow")
        for (index, track) in tracks.enumerated() {
            if let row = trackTable.rowController(at: index) as? TrackRow {
                row.titleLabel.setText(track.name)
                row.artistLabel.setText(track.artist)
                guard let url = track.thumbnail else { return }
                SDWebImageManager.shared().loadImage(with: url, progress: nil) { image, _, _, _, _, _ in
                    row.thumbnailView.setImage(image)
                }
            }
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        WatchManager.shared.watchSession?.sendMessage([
            "type": "play",
            "source": "library",
            "index": rowIndex
        ], replyHandler: nil)
    }

}
