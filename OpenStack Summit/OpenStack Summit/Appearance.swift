//
//  Appearance.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 7/7/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit

func SetAppearance() {
    
    UINavigationBar.appearance().translucent = false
    UINavigationBar.appearance().barStyle = UIBarStyle.Black
    UINavigationBar.appearance().barTintColor = UIColor(hexaString: "#214065")
    UINavigationBar.appearance().tintColor = UIColor.whiteColor()
    
    UISearchBar.appearance().tintColor = UIColor(hexaString: "#214065")
}
