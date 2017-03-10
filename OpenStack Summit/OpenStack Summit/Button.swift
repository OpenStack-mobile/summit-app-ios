//
//  Button.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/15/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class Button: UIButton {
    
    // MARK: - Properties
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        
        didSet {
            
            layer.cornerRadius = self.cornerRadius
            
            layer.masksToBounds = cornerRadius > 0.0
        }
    }
    
    @IBInspectable var color: UIColor?
    
    @IBInspectable var selectedColor: UIColor?
    
    // MARK: - Methods
    
    override var highlighted: Bool {
        
        didSet {
            
            let defaultColor = self.color ?? self.backgroundColor ?? .clearColor()
            
            let selectedColor = self.selectedColor ?? defaultColor
            
            if highlighted {
                
                self.backgroundColor = selectedColor
                
            } else {
                
                self.backgroundColor = defaultColor
            }
            
            setNeedsDisplay()
        }
    }
}
