//
//  ScheduleCellViewTableViewCell.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IScheduleTableViewCell : class {
    var eventTitle: String! { get set }
    var timeAndPlace: String! { get set }
    var scheduledButtonText: String! { get set }
}


class ScheduleTableViewCell: UITableViewCell, IScheduleTableViewCell {
    var eventTitle: String!{
        get {
            return eventTitleLabel.text
        }
        set {
            eventTitleLabel.text = newValue
        }
    }
    
    var timeAndPlace: String!{
        get {
            return timeAndPlaceLabel.text
        }
        set {
            timeAndPlaceLabel.text = newValue
        }
    }
    
    var scheduledButtonText: String! {
        get {
            return scheduleButton.titleForState(.Normal)
        }
        set {
            scheduleButton.setTitle(newValue, forState: .Normal)
        }
    }

    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var timeAndPlaceLabel: UILabel!
    @IBOutlet weak var scheduleButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
