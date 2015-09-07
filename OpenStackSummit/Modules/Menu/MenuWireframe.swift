//
//  MenuWireframe.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/24/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IMenuWireframe {
    
}

public class MenuWireframe: NSObject, IMenuWireframe {
    var menuViewController: MenuViewController!
    var venueListWireframe: IVenueListWireframe!
}
