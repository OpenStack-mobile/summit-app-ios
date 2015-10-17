//
//  MyFeedbackTableViewCell.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IFeedbackGivenTableViewCell : class {
    var eventName: String! { get set }
    var owner: String! { get set }
    var rate: String! { get set }
    var review: String! { get set }
    var date: String! { get set }
}

class FeedbackGivenTableViewCell: UITableViewCell, IFeedbackGivenTableViewCell {
    var eventName: String!{
        get {
            return eventNameLabel.text
        }
        set {
            eventNameLabel.text = newValue
        }
    }
    
    var owner: String!{
        get {
            return ownerLabel.text
        }
        set {
            ownerLabel.text = newValue
        }
    }

    var rate: String!{
        get {
            return rateLabel.text
        }
        set {
            rateLabel.text = newValue
        }
    }

    var review: String!{
        get {
            return reviewLabel.text
        }
        set {
            reviewLabel.text = newValue
        }
    }

    var date: String!{
        get {
            return dateLabel.text
        }
        set {
            dateLabel.text = newValue
        }
    }
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}