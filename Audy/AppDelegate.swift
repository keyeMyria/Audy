//
//  AppDelegate.swift
//  Audy
//
//  Created by Sammy Yousif on 8/28/17.
//  Copyright © 2017 Sammy Yousif. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let _ = Spotify.shared
        let _ = Soundcloud.shared
        let _ = MusicLibrary.shared
        let _ = Player.shared
        let _ = WatchManager.shared
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.black
        window?.rootViewController = NavigationController.shared
        window?.makeKeyAndVisible()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let host = url.host else { return false }
        switch host {
        case "spotify":
            Spotify.shared.handleLogin(url)
            return true
        default:
            return false
        }
    }

}

