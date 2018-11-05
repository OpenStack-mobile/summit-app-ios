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
    
    func dismissActivityIndicator(_ animated: Bool)
}

#if os(iOS)

extension ActivityViewController {
    
    func showActivityIndicator() {
        
        showActivityIndicator(withMessage: nil)
    }
    
    func showActivityIndicator(withMessage message: String?) {
        
        view.isUserInteractionEnabled = false
        
        progressHUD.show(in: view)
        
        progressHUD.textLabel.text = message
        
        view.bringSubview(toFront: progressHUD)
    }
    
    func dismissActivityIndicator(_ animated: Bool = true) {
        
        view.isUserInteractionEnabled = true
        
        progressHUD.dismiss(animated: animated)
    }
}

#endif
