//
//  MainWindowController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/19/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit

final class MainWindowController: NSWindowController {
    
    var appWindow: INAppStoreWindow {
        
        return self.window as! INAppStoreWindow
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        appWindow.centerTrafficLightButtons = true
        appWindow.titleBarView = self.window?.toolbar
    }
}
