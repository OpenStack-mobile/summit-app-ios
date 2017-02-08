//
//  PresentPopover.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/7/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func present(viewController viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, sender: PopoverPresentingView) {
        
        switch sender {
            
        case let .View(view):
            
            viewController.popoverPresentationController?.sourceRect = view.bounds
            viewController.popoverPresentationController?.sourceView = view
            
        case let .BarButtonItem(tabBarItem):
            
            viewController.popoverPresentationController?.barButtonItem = tabBarItem
        }
        
        self.presentViewController(viewController, animated: animated, completion: completion)
    }
}

// MARK: - Supporting Types

enum PopoverPresentingView {
    
    case View(UIView)
    case BarButtonItem(UIBarButtonItem)
}
