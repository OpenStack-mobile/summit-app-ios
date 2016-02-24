//
//  NavigationController.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 2/22/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.tintColor = UIColor.whiteColor()
        navigationBar.barStyle = UIBarStyle.BlackTranslucent
        navigationBar.barTintColor = UIColor(red: 33/255, green: 64/255, blue: 101/255, alpha: 1.0)
        navigationBar.translucent = false
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        toolbar.barTintColor = UIColor(hexaString: "#F8E71C")
    }
}
