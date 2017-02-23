//
//  ContentController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/23/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import CoreSummit

protocol ContentController: class {
    
    associatedtype Content = Unique
    
    var contentIdentifier: Identifier { get set }
}
