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
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        
        userInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(CopyableLabel.showMenu(_:))))
    }
    
    // MARK: - Actions
    
    func showMenu(sender: AnyObject?) {
        
        becomeFirstResponder()
        
        let menuController = UIMenuController.sharedMenuController()
        if !menuController.menuVisible {
            menuController.setTargetRect(bounds, inView: self)
            menuController.setMenuVisible(true, animated: true)
        }
    }
    
    override func copy(sender: AnyObject?) {
        
        let pasteBoard = UIPasteboard.generalPasteboard()
        pasteBoard.string = text
        let menuController = UIMenuController.sharedMenuController()
        menuController.setMenuVisible(false, animated: true)
    }
    
    // MARK: - Methods
    
    override func canBecomeFirstResponder() -> Bool {
        
        return true
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        
        return action == #selector(NSObject.copy)
    }
}
