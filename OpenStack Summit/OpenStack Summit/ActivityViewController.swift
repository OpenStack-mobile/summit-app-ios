//
//  ActivityViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/16/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

#if os(iOS)
import UIKit
import JGProgressHUD
#endif

protocol ActivityViewController {
    
    #if os(iOS)
    
    var view: UIView! { get }
    
    var progressHUD: JGProgressHUD { get }
    
    #endif
    
    func showActivityIndicator()
    
    func dismissActivityIndicator(animated animated: Bool)
}

#if os(iOS)

extension ActivityViewController {
    
    func showActivityIndicator() {
        
        view.userInteractionEnabled = false
        
        progressHUD.showInView(view)
        
        view.bringSubviewToFront(progressHUD)
    }
    
    func dismissActivityIndicator(animated animated: Bool = true) {
        
        view.userInteractionEnabled = true
        
        progressHUD.dismissAnimated(animated)
    }
}

#endif
