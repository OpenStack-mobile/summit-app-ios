//
//  UXKit.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/18/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

#if os(iOS) || os(tvOS)
    
    typealias ViewController = UIViewController
    typealias TableViewDataSource = UITableViewDataSource
    typealias TableView = UITableView
    
#elseif os(OSX)
    
    typealias UIViewController = NSViewController
    typealias UITableViewDataSource = NSTableViewDataSource
    typealias UITableView = NSTableView
    
    extension NSIndexPath {
        
        @inline(__always)
        convenience init(forRow row: Int, inSection section: Int) {
            
            self.init(forItem: row, inSection: section)
        }
    }
    
#endif
