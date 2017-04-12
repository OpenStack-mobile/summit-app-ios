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
    
    @IBOutlet fileprivate(set) weak var dateTimeLabel: UILabel!
    @IBOutlet fileprivate(set) weak var nameLabel: UILabel!
    @IBOutlet fileprivate(set) weak var trackLabel: UILabel!
    @IBOutlet fileprivate(set) weak var statusImageView: UIImageView!
    @IBOutlet fileprivate(set) weak var contextMenuButton: UIButton!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        
    }
}
