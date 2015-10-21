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
    var scheduledStatus: ScheduledStatus { get set }
    var isScheduledStatusVisible: Bool { get set }
}

@objc public enum ScheduledStatus: Int {
    case Scheduled, NotScheduled
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
    
    var scheduledStatus: ScheduledStatus {
        get {
            return scheduleButton.titleForState(.Normal) == "remove" ? .Scheduled : .NotScheduled
        }
        set {
            if (newValue == .Scheduled) {
                scheduleButton.setTitle("remove", forState: .Normal)
            }
            else {
                scheduleButton.setTitle("schedule", forState: .Normal)
            }
        }
    }
    
    var isScheduledStatusVisible: Bool {
        get {
            return !scheduleButton.hidden
        }
        set {
            scheduleButton.hidden = !newValue
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
