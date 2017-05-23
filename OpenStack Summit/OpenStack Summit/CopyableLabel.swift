//
//  CopyableLabel.swift
//  OpenStack Summit
//
//  Created by Gabriel Horacio Cutrini on 8/10/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit

final class CopyableLabel: UILabel {
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isUserInteractionEnabled = true
    }
    
    private func setup() {
        
        isUserInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(CopyableLabel.showMenu(_:))))
    }
    
    // MARK: - Actions
    
    func showMenu(_ sender: AnyObject?) {
        
        becomeFirstResponder()
        
        let menuController = UIMenuController.shared
        if !menuController.isMenuVisible {
            menuController.setTargetRect(bounds, in: self)
            menuController.setMenuVisible(true, animated: true)
        }
    }
    
    override func copy(_ sender: Any?) {
        
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = text
        let menuController = UIMenuController.shared
        menuController.setMenuVisible(false, animated: true)
    }
    
    // MARK: - Methods
    
    override var canBecomeFirstResponder : Bool {
        
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        
        switch action {
            
        case #selector(UIResponderStandardEditActions.copy):
            
            return true
            
        default:
            
            return false
        }
    }
}
