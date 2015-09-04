//
//  Router.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/4/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public protocol IRouter {
    
}

public class Router: NSObject, IRouter {
    
    var storyboard: UIStoryboard!
    var navigationController = UINavigationController();
    
    public func navigateTo(identifier: String) {
        let viewController = storyboard.instantiateViewControllerWithIdentifier(identifier);
        navigationController.pushViewController(viewController, animated: true)
    }
}
