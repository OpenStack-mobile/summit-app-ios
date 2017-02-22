//
//  ScheduleCellViewTableViewCell.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

final class ScheduleTableViewCell: UITableViewCell {
    
    // MARK: - IB Outlets
    
    @IBOutlet private(set) weak var dateTimeLabel: UILabel!
    @IBOutlet private(set) weak var nameLabel: UILabel!
    @IBOutlet private(set) weak var trackLabel: UILabel!
    @IBOutlet private(set) weak var statusImageView: UIImageView!
    @IBOutlet private(set) weak var contextMenuButton: UIButton!
    
}
