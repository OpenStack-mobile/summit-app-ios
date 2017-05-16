//
//  LabelCellController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import WatchKit

final class LabelCellController: NSObject {
    
    static let identifier = "LabelCell"
    
    @IBOutlet private(set) weak var textLabel: WKInterfaceLabel!
}
