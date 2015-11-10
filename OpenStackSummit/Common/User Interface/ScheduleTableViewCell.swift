//
//  ScheduleCellViewTableViewCell.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IScheduleTableViewCell : IScheduleableView {
    var eventTitle: String! { get set }
    var eventType: String! { get set }
    var time: String! { get set }
    var place: String! { get set }
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
    
    var eventType: String!{
        get {
            return eventTypeLabel.text?.uppercaseString
        }
        set {
            eventTypeLabel.text = newValue
        }
    }
    
    var time: String!{
        get {
            return timeLabel.text
        }
        set {
            timeLabel.text = newValue
        }
    }
    
    var place: String!{
        get {
            return placeLabel.text
        }
        set {
            placeLabel.text = newValue
        }
    }
    
    var scheduled: Bool {
        get {
            return scheduleButton.titleForState(.Normal) == "remove"
        }
        set {
            if (newValue) {
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
    @IBOutlet weak var eventTypeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
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
