//
//  UIColor+HexString.swift
//  OpenStackSummit
//
//  Created by Claudio on 11/30/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

extension UIColor {
    
    convenience init?(hexString: String) {
        
        guard hexString.isEmpty == false
            && hexString.count == 7
            else { return nil }
        
        self.init(
            red:   CGFloat( strtoul( String(Array(hexString)[1...2]), nil, 16) ) / 255.0,
            green: CGFloat( strtoul( String(Array(hexString)[3...4]), nil, 16) ) / 255.0,
            blue:  CGFloat( strtoul( String(Array(hexString)[5...6]), nil, 16) ) / 255.0, alpha: 1 )
    }
}
