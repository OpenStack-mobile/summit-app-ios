//
//  Button.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/15/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import UIKit

/// Customizable button.
@IBDesignable class Button: UIButton {
    
    // MARK: - Properties
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        
        didSet { configureView() }
    }
    
    @IBInspectable var color: UIColor? {
        
        didSet { configureView() }
    }
    
    @IBInspectable var selectedColor: UIColor? {
        
        didSet { configureView() }
    }
    
    override var isHighlighted: Bool {
        
        didSet { configureView() }
    }
    
    // MARK: - Loading
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureView()
    }
    
    // MARK: - Methods
    
    private func configureView() {
        
        // cornerRadius
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = cornerRadius > 0.0
        
        // background color
        let defaultColor = self.color ?? self.backgroundColor ?? .clear
        let selectedColor = self.selectedColor ?? defaultColor
        
        if isHighlighted {
            
            self.backgroundColor = selectedColor
            
        } else {
            
            self.backgroundColor = defaultColor
        }
        
        setNeedsDisplay()
    }
}
