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
        
        userInteractionEnabled = true
    }
    
    private func setup() {
        
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
        
        switch action {
            
        case #selector(UIResponderStandardEditActions.copy):
            
            return true
            
        default:
            
            return false
        }
    }
}
