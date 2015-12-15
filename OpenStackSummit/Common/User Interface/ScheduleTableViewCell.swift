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
    var sponsors: String! { get set }
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
            return eventNameLabel.text
        }
        set {
            eventNameLabel.text = newValue
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
    
    var sponsors: String!{
        get {
            return sponsorsLabel.text
        }
        set {
            let spacing = 3
            let attributedString = NSAttributedString(string: newValue, attributes: [NSKernAttributeName: spacing])
            sponsorsLabel.attributedText = attributedString
        }
    }
    
    var track: String!{
        get {
            return trackLabel.text
        }
        set {
            trackLabel.text = newValue
            trackLabel.sizeToFit()
        }
    }
    
    var scheduled: Bool  {
        get {
            return scheduledInternal
        }
        set {
            scheduledInternal = newValue
            if (scheduledInternal) {
                scheduleButton.setImage(UIImage(named:"schedule_checked_active")!, forState: .Normal)
            }
            else {
                scheduleButton.setImage(UIImage(named:"schedule_unchecked")!, forState: .Normal)
            }
        }
    }
    
    var summitTypeColor: UIColor? {
        get {
            return eventNameLabel.textColor
        }
        set {
            sponsorsLabel.textColor = newValue != nil ? newValue : UIColor(hexaString: "#4A4A4A")
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

    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventTypeLabel: UILabel!
    @IBOutlet weak var eventTypeVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var sponsorsLabel: UILabel!
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if trackLabel.text == "" && sponsorsLabel.text != "" {
            contentView.removeConstraint(eventTypeVerticalConstraint)
            eventTypeVerticalConstraint = NSLayoutConstraint(item: eventTypeLabel, attribute: NSLayoutAttribute.FirstBaseline, relatedBy: NSLayoutRelation.Equal, toItem:
                sponsorsLabel, attribute: NSLayoutAttribute.FirstBaseline, multiplier: CGFloat(1), constant: CGFloat(0))
            contentView.addConstraint(eventTypeVerticalConstraint)

            for constraint in contentView.constraints {
                if constraint.firstItem as? UIView == eventTypeLabel && constraint.secondItem as? UIView == contentView && constraint.secondAttribute == NSLayoutAttribute.BottomMargin {
                    contentView.removeConstraint(constraint)
                }
            }
        }
        else if trackLabel.text != "" {
            contentView.removeConstraint(eventTypeVerticalConstraint)
            eventTypeVerticalConstraint = NSLayoutConstraint(item: eventTypeLabel, attribute: NSLayoutAttribute.FirstBaseline, relatedBy: NSLayoutRelation.Equal, toItem:
                trackLabel, attribute: NSLayoutAttribute.FirstBaseline, multiplier: CGFloat(1), constant: CGFloat(0))
            contentView.addConstraint(eventTypeVerticalConstraint)
            
            for constraint in contentView.constraints {
                if constraint.firstItem as? UIView == eventTypeLabel && constraint.secondItem as? UIView == contentView && constraint.secondAttribute == NSLayoutAttribute.BottomMargin {
                    contentView.removeConstraint(constraint)
                }
            }
        }
        else if trackLabel.text == "" && sponsorsLabel.text == "" {
            contentView.removeConstraint(eventTypeVerticalConstraint)
            eventTypeVerticalConstraint = NSLayoutConstraint(item: eventTypeLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem:
                eventNameLabel, attribute: NSLayoutAttribute.Bottom, multiplier: CGFloat(1), constant: CGFloat(0))
            contentView.addConstraint(eventTypeVerticalConstraint)
            
            for constraint in contentView.constraints {
                if constraint.firstItem as? UIView == eventTypeLabel && constraint.secondItem as? UIView == contentView && constraint.secondAttribute == NSLayoutAttribute.BottomMargin {
                    contentView.removeConstraint(constraint)
                }
            }
            let eventTypeBottomConstraint = NSLayoutConstraint(item: eventTypeLabel, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem:
                contentView, attribute: NSLayoutAttribute.BottomMargin, multiplier: CGFloat(1), constant: CGFloat(-10))
            contentView.addConstraint(eventTypeBottomConstraint)
            
        }
        
        contentView.updateConstraintsIfNeeded()
    }
}
