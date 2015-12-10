//
//  MyFeedbackTableViewCell.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Cosmos

@objc
public protocol IFeedbackTableViewCell : class {
    var eventName: String! { get set }
    var owner: String! { get set }
    var rate: Double { get set }
    var review: String! { get set }
    var date: String! { get set }
}

class FeedbackTableViewCell: UITableViewCell, IFeedbackTableViewCell {
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
    
    var rate: Double{
        get {
            return rateView.rating
        }
        set {
            rateView.rating = newValue
            rateViewWidthConstraint.constant = CGFloat(17*newValue) + 5.0
        }
    }
    
    var review: String!{
        get {
            return reviewLabel.text
        }
        set {
            reviewLabel.text = newValue
            reviewLabel.sizeToFit()
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
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var rateView: CosmosView!
    
    @IBOutlet weak var rateViewWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        rateView.settings.updateOnTouch = false
        // Initialization code
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
        // Set up UI
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}