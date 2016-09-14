//
//  ScheduleCellViewTableViewCell.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public enum ScheduledStatus {
    
    case Scheduled, NotScheduled
}

final class ScheduleTableViewCell: UITableViewCell, ScheduleableView {
    
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
    
    var location: String {
        get {
            return locationLabel.text ?? ""
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
    
    var scheduled: Bool = false  {
        
        didSet {
            
            if (scheduled) {
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
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventTypeLabel: UILabel!
    @IBOutlet weak var eventTypeLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventTypeLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventTypeLabelBaselineConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var sponsorsLabel: UILabel!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var locationPinImage: UIImageView!
    @IBOutlet weak var scheduleButton: UIButton!
    @IBOutlet weak var trackGroupColorBar: UIView!
    
    // MARK: - Loading
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.clearColor()
        selectedBackgroundView = bgColorView
    }
    
    override func layoutSubviews() {
        
        eventTypeLabelWidthConstraint.constant = 0
        
        contentView.removeConstraint(eventTypeLabelBaselineConstraint)
        if eventTypeLabelTopConstraint != nil {
            contentView.removeConstraint(eventTypeLabelTopConstraint)
        }
        
        if sponsorsLabel.text != "" && trackLabel.text == "" {
            eventTypeLabelBaselineConstraint = NSLayoutConstraint(item: eventTypeLabel, attribute: NSLayoutAttribute.FirstBaseline, relatedBy: NSLayoutRelation.Equal, toItem:
                sponsorsLabel, attribute: NSLayoutAttribute.FirstBaseline, multiplier: CGFloat(1), constant: CGFloat(0))
        }
        else {
            var toItem = locationLabel.text == "" ? eventNameLabel : locationLabel
            if sponsorsLabel.text != "" {
                toItem = sponsorsLabel
            }
            
            var toItemDistance = 15
            if toItem == locationLabel && sponsorsLabel.text == "" && trackLabel.text == "" {
                toItemDistance = 13
                eventTypeLabelWidthConstraint.constant = 50
            }
            
            eventTypeLabelTopConstraint = NSLayoutConstraint(item: eventTypeLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem:
                toItem, attribute: NSLayoutAttribute.Bottom, multiplier: CGFloat(1), constant: CGFloat(toItemDistance))
            
            contentView.addConstraint(eventTypeLabelTopConstraint)
            
            eventTypeLabelBaselineConstraint = NSLayoutConstraint(item: eventTypeLabel, attribute: NSLayoutAttribute.LastBaseline, relatedBy: NSLayoutRelation.Equal, toItem:
                trackLabel, attribute: NSLayoutAttribute.FirstBaseline, multiplier: CGFloat(1), constant: CGFloat(0))
        }
        
        contentView.addConstraint(eventTypeLabelBaselineConstraint)
        
        super.layoutSubviews()
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
