//
//  NavigationController.swift
//  Audy
//
//  Created by Sammy Yousif on 8/30/17.
//  Copyright © 2017 Sammy Yousif. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    static let shared: NavigationController = {
        let root = RootController()
        let navigator = NavigationController(rootViewController: root)
        return navigator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.backgroundColor = UIColor.white
        setNavigationBarHidden(true, animated: false)
        automaticallyAdjustsScrollViewInsets = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
