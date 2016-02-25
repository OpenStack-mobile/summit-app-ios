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
        
        navigationBar.translucent = false
        navigationBar.barStyle = UIBarStyle.Black
        navigationBar.barTintColor = UIColor(hexaString: "#214065")
        navigationBar.tintColor = UIColor.whiteColor()
    }
}
