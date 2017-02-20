//
//  UXKit.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/18/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit

typealias UIColor = NSColor
typealias UIViewController = NSViewController
typealias UITableViewDataSource = NSTableViewDataSource
typealias UITableViewDelegate = NSTableViewDelegate
typealias UITableView = NSTableView
typealias UITableViewCell = NSTableCellView

extension NSIndexPath {
    
    @inline(__always)
    convenience init(forRow row: Int, inSection section: Int) {
        
        self.init(forItem: row, inSection: section)
    }
}
