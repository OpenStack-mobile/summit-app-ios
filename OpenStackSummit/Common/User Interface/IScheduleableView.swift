//
//  IScheduleableView.swift
//  OpenStackSummit
//
//  Created by Claudio on 11/10/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IScheduleableView {
    var scheduled: Bool { get set }
}
