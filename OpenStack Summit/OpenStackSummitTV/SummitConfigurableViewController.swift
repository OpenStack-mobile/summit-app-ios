//
//  SummitConfigurableViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/25/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import typealias CoreSummit.Identifier

public protocol SummitConfigurableViewController: class {
    
    var summit: Identifier! { get set }
}