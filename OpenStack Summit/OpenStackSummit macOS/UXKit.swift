//
//  UXKit.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/18/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit

public typealias UIColor = NSColor
public typealias UIImage = NSImage
public typealias UIViewController = NSViewController
public typealias UITableViewDataSource = NSTableViewDataSource
public typealias UITableViewDelegate = NSTableViewDelegate
public typealias UITableView = NSTableView
public typealias UITableViewCell = NSTableCellView

public extension NSIndexPath {
    
    @inline(__always)
    convenience init(forRow row: Int, inSection section: Int) {
        
        self.init(forItem: row, inSection: section)
    }
}
