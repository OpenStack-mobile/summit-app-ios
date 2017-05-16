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

public extension IndexPath {
    
    @inline(__always)
    init(forRow row: Int, inSection section: Int) {
        
        self.init(item: row, section: section)
    }
}

extension NSPopover {
    
    static var windowClassName: String { return "_NSPopoverWindow" }
}
