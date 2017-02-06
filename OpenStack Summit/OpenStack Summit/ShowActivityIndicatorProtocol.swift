//
//  ShowActivityIndicatorProtocol.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/16/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

protocol ShowActivityIndicatorProtocol {
    
    func showActivityIndicator()
    
    func hideActivityIndicator()
}

#if os(iOS)

import SwiftSpinner

extension ShowActivityIndicatorProtocol {
    
    func showActivityIndicator() {
        
        SwiftSpinner.showWithDelay(0.5, title: "Please wait...")
    }
    
    func hideActivityIndicator() {
        
        SwiftSpinner.hide()
    }
}

#endif
