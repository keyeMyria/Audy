//
//  RootController.swift
//  Audy
//
//  Created by Sammy Yousif on 8/31/17.
//  Copyright © 2017 Sammy Yousif. All rights reserved.
//

import UIKit

class RootController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let controllers = [LibraryController(), AccountsController()]
        let pageController = PageController(frame: UIScreen.main.bounds, viewControllers: controllers)
        pageController.infiniteDelegate = self
        addChildViewController(pageController)
        view.addSubview(pageController.view)
        pageController.didMove(toParentViewController: self)
        
        let playerController = PlayerController()
        addChildViewController(playerController)
        view.addSubview(playerController.view)
        playerController.didMove(toParentViewController: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension RootController: PageDelegate {
    func pageViewCurrentIndex(_ currentIndex: Int) {
        
    }
}
