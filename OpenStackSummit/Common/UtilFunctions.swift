//
//  UtilFunctions.swift
//  OpenStackSummit
//
//  Created by Claudio on 4/8/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit

func printerr(items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    Swift.print(items[0], separator:separator, terminator: terminator)
    Swift.print(NSThread.callStackSymbols())
    #endif
}

func printdeb(items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        Swift.print(items[0], separator:separator, terminator: terminator)
    #endif
}