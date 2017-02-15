//
//  Button.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/15/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable final class Button: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        
        didSet {
            
            layer.cornerRadius = self.cornerRadius
            
            layer.masksToBounds = cornerRadius > 0.0
        }
    }
}
