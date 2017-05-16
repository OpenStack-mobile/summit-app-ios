//
//  Appearance.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 7/7/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit

func SetAppearance() {
    
    UINavigationBar.appearance().isTranslucent = false
    UINavigationBar.appearance().barStyle = UIBarStyle.black
    UINavigationBar.appearance().barTintColor = UIColor(hexString: "#214065")
    UINavigationBar.appearance().tintColor = UIColor.white
    UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "OpenSans-Semibold", size: 17)!]
    
    UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "OpenSans-Semibold", size: 17)!], for: UIControlState())
    
    UISearchBar.appearance().tintColor = UIColor(hexString: "#214065")
}
