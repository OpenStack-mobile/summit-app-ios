//
//  SearchViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/21/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import AppKit

protocol SearchableController: class {
    
    var searchTerm: String { get set }
}
