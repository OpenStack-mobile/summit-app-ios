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
    var track: String! { get set }
    var isScheduledStatusVisible: Bool { get set }
    var summitTypeColor: UIColor? { get set }
}

@objc public enum ScheduledStatus: Int {
    case Scheduled, NotScheduled
}

class ScheduleTableViewCell: UITableViewCell, IScheduleTableViewCell {
    
    private var scheduledInternal = false

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
            return eventTypeLabel.text
        }
        set {
            eventTypeLabel.text = newValue?.uppercaseString
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
    
    var track: String!{
        get {
            return trackLabel.text
        }
        set {
            trackLabel.text = newValue
        }
    }
    
    var scheduled: Bool  {
        get {
            return scheduledInternal
        }
        set {
            scheduledInternal = newValue
            if (scheduledInternal) {
                scheduleButton.setImage(UIImage(named:"checked_active")!, forState: .Normal)
            }
            else {
                scheduleButton.setImage(UIImage(named:"unchecked")!, forState: .Normal)
            }
        }
    }
    
    var summitTypeColor: UIColor? {
        get {
            return eventTitleLabel.textColor
        }
        set {
            eventTitleLabel.textColor = newValue != nil ? newValue : UIColor.blackColor()
            summitTypeColorBar.backgroundColor = newValue != nil ? newValue : UIColor.lightGrayColor()
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
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var scheduleButton: UIButton!
    @IBOutlet weak var summitTypeColorBar: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let bgColorView = UIView()
        bgColorView.backgroundColor = contentView.backgroundColor
        selectedBackgroundView = bgColorView
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }    
}
