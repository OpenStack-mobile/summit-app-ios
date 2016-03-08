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
    var location: String! { get set }
    var sponsors: String! { get set }
    var track: String! { get set }
    var isScheduledStatusVisible: Bool { get set }
    var trackGroupColor: UIColor? { get set }
}

@objc public enum ScheduledStatus: Int {
    case Scheduled, NotScheduled
}

class ScheduleTableViewCell: UITableViewCell, IScheduleTableViewCell {
    
    private var locationInternal = ""
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
    
    var location: String!{
        get {
            return locationLabel.text
        }
        set {
            locationLabel.text = newValue
            locationPinImage.hidden = newValue.isEmpty
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
    
    var trackGroupColor: UIColor? {
        get {
            return trackGroupColorBar.backgroundColor
        }
        set {
            if newValue != nil {
                trackGroupColorBar.hidden = false
                trackGroupColorBar.backgroundColor = newValue != nil ? newValue : UIColor.lightGrayColor()
            } else {
                trackGroupColorBar.hidden = true
            }
            sponsorsLabel.textColor = newValue != nil ? newValue : UIColor(hexaString: "#4A4A4A")
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
    @IBOutlet weak var eventTypeLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventTypeLabelBaselineConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var sponsorsLabel: UILabel!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var locationPinImage: UIImageView!
    @IBOutlet weak var scheduleButton: UIButton!
    @IBOutlet weak var trackGroupColorBar: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.clearColor()
        selectedBackgroundView = bgColorView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.removeConstraint(eventTypeLabelBaselineConstraint)
        if eventTypeLabelTopConstraint != nil {
            contentView.removeConstraint(eventTypeLabelTopConstraint)
        }
        
        if sponsorsLabel.text != "" && trackLabel.text == "" {
            eventTypeLabelBaselineConstraint = NSLayoutConstraint(item: eventTypeLabel, attribute: NSLayoutAttribute.FirstBaseline, relatedBy: NSLayoutRelation.Equal, toItem:
                sponsorsLabel, attribute: NSLayoutAttribute.FirstBaseline, multiplier: CGFloat(1), constant: CGFloat(0))
        }
        else {
            let toItem = locationLabel.text == "" ? eventNameLabel : locationLabel
            eventTypeLabelTopConstraint = NSLayoutConstraint(item: eventTypeLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem:
                toItem, attribute: NSLayoutAttribute.Bottom, multiplier: CGFloat(1), constant: CGFloat(12))
            
            contentView.addConstraint(eventTypeLabelTopConstraint)
            
            eventTypeLabelBaselineConstraint = NSLayoutConstraint(item: eventTypeLabel, attribute: NSLayoutAttribute.Baseline, relatedBy: NSLayoutRelation.Equal, toItem:
                trackLabel, attribute: NSLayoutAttribute.FirstBaseline, multiplier: CGFloat(1), constant: CGFloat(0))
        }
        
        contentView.addConstraint(eventTypeLabelBaselineConstraint)
        contentView.updateConstraintsIfNeeded()
    }
    

    override func setSelected(selected: Bool, animated: Bool) {
        // On cell selected, internal views lose background color http://stackoverflow.com/questions/6745919/uitableviewcell-subview-disappears-when-cell-is-selected
        let color = trackGroupColorBar.backgroundColor
        super.setSelected(selected, animated: animated)
        
        if selected {
            trackGroupColorBar.backgroundColor = color
        }
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        let color = trackGroupColorBar.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            trackGroupColorBar.backgroundColor = color
        }
    }
}
