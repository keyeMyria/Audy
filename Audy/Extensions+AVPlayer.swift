//
//  Extensions+AVPlayer.swift
//  Audy
//
//  Created by Sammy Yousif on 9/1/17.
//  Copyright © 2017 Sammy Yousif. All rights reserved.
//

import Foundation
import AVFoundation

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
