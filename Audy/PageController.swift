//
//  PageController.swift
//  Audy
//
//  Created by Sammy Yousif on 8/29/17.
//  Copyright © 2017 Sammy Yousif. All rights reserved.
//

import Foundation

import UIKit

public protocol PageDelegate: class {
    func pageViewCurrentIndex(_ currentIndex: Int)
}

open class PageController: UIPageViewController {
    fileprivate var controllers: [UIViewController]
    open weak var infiniteDelegate: PageDelegate?
    
    public init(frame: CGRect, viewControllers: [UIViewController]) {
        controllers = viewControllers
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        for view in view.subviews {
            if view is UIScrollView {
                (view as! UIScrollView).delaysContentTouches = false
            }
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        guard let firstViewController = controllers.first else {
            return
        }
        
        setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
    }
}

extension PageController: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }
        var currentIndex: Int!
        let vc = pageViewController.viewControllers!.first!
        if (vc is LibraryController) {
            currentIndex = 0
        }
        else if (vc is AccountsController) {
            currentIndex = 1
        }
        infiniteDelegate?.pageViewCurrentIndex(currentIndex)
    }
}

extension PageController: UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = controllers.index(of: viewController) else {
            return nil
        }
        
        // infiniteDelegate?.pageViewCurrentIndex(index)
        
        if index == 0 {
            return controllers[controllers.count-1]
        }
        
        let previousIndex = index - 1
        return controllers[previousIndex]
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = controllers.index(of: viewController) else {
            return nil
        }
        
        // infiniteDelegate?.pageViewCurrentIndex(index)
        
        let nextIndex = index + 1
        if nextIndex == controllers.count {
            
            return controllers.first
        }
        
        return controllers[nextIndex]
    }
}
