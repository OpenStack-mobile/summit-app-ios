//
//  UIColor+HexString.swift
//  OpenStackSummit
//
//  Created by Claudio on 11/30/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hexaString:String) {
        self.init(
            red:   CGFloat( strtoul( String(Array(hexaString.characters)[1...2]), nil, 16) ) / 255.0,
            green: CGFloat( strtoul( String(Array(hexaString.characters)[3...4]), nil, 16) ) / 255.0,
            blue:  CGFloat( strtoul( String(Array(hexaString.characters)[5...6]), nil, 16) ) / 255.0, alpha: 1 )
    }
}
