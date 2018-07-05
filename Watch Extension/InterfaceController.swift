//
//  InterfaceController.swift
//  Watch Extension
//
//  Created by Sammy Yousif on 9/1/17.
//  Copyright © 2017 Sammy Yousif. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController {

    @IBOutlet var navigationTableView: WKInterfaceTable!
    
    let links = ["Library"]
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let _ = MusicLibrary.shared
        let _ = WatchManager.shared
        setupNavigation()
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    func setupNavigation() {
        navigationTableView.setNumberOfRows(links.count, withRowType: "NavigationRow")
        for (index, text) in links.enumerated() {
            if let row = navigationTableView.rowController(at: index) as? NavigationRow {
                row.linkLabel.setText(text)
            }
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        self.pushController(withName: "library", context: nil)
    }

}
