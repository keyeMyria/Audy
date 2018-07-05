//
//  File.swift
//  Audy
//
//  Created by Sammy Yousif on 9/2/17.
//  Copyright © 2017 Sammy Yousif. All rights reserved.
//

import Foundation
import RxSwift

class MusicLibrary: NSObject {
    static let shared = MusicLibrary()
    
    let tracks = Variable<[Track]>([])
}
